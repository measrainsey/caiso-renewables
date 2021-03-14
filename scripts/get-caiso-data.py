'''
this script pulls and combines CAISO's hourly breakdown of renewable sources (which is reported for each day).
an example of the report is: http://content.caiso.com/green/renewrpt/20200101_DailyRenewablesWatch.txt
'''

import pandas as pd
from datetime import date, datetime, timedelta
import os

# specify start and end dates -------
start_date = '2020-01-01'
end_date = '2020-12-31'

# get dates between specified start and end dates -----
dates = pd.date_range(start_date, end_date, freq = 'd')

# base url of hourly breakdown reports -----
base_url = 'http://content.caiso.com/green/renewrpt'

# loop through dates to access URLs for all dates of hourly breakdown reports -------
print('Gathering data...')
appended_dfs = []
for i in range(0, dates.size):
    '''
    for each date, add the date to the base url and complete the url to get the needed url to access the data.
    then, read each report in as a pandas dataframe
    each dataframe is appended to the appended_dfs list
    '''
    get_url = os.path.join(base_url, datetime.strftime(dates[i], '%Y%m%d') + '_DailyRenewablesWatch.txt')
    df = pd.read_csv(get_url, header = 1, sep = '\t', lineterminator = '\r', nrows = 24, usecols = [1,3,5,7,9,11,13,15])
    df.columns = ['Hour', 'GEOTHERMAL', 'BIOMASS', 'BIOGAS', 'SMALL HYDRO', 'WIND TOTAL', 'SOLAR PV', 'SOLAR THERMAL']
    df[['date']] = dates[i]
    df = df[['date', 'Hour',
             'GEOTHERMAL', 'BIOMASS', 'BIOGAS', 'SMALL HYDRO',
             'WIND TOTAL', 'SOLAR PV', 'SOLAR THERMAL']]

    appended_dfs.append(df)

# concat the list of dataframes into one dataframe -----
df_caiso = pd.concat(appended_dfs, axis=0, sort=False)

# rename columns ------
df_caiso.columns= df_caiso.columns.str.lower()
df_caiso.columns = df_caiso.columns.str.replace(' ','_')

# convert columns to numeric -------
cols = ['geothermal', 'biomass', 'biogas', 'small_hydro', 'wind_total', 'solar_pv', 'solar_thermal']
df_caiso[cols] = df_caiso[cols].apply(pd.to_numeric, errors = 'coerce')

# find daily total generation of each renewable source ------
print('Data collection complete. Now processing data...')

df_daily = df_caiso[['date', 'geothermal', 'biomass', 'biogas', 'small_hydro',
                     'wind_total', 'solar_pv', 'solar_thermal']].groupby(['date']).sum().reset_index()

# save dataframes to csv ------
print('Data processing complete. Now saving files...')

raw_path = os.path.join(os.getcwd(), 'data', 'caiso_renewables_hourly_' + start_date + '_' + end_date + '.csv')
df_caiso.to_csv(raw_path, index = False)
print('Raw data has been saved to ' + raw_path)

process_path = os.path.join(os.getcwd(), 'data', 'caiso_renewables_daily_' + start_date + '_' + end_date + '.csv')
df_daily.to_csv(process_path, index = False)
print('Processed data has been saved to ' + raw_path)