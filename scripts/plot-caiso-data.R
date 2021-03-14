# script to create ridgeline plots of caiso renewable generation
# author: @measrainsey

# inputs ------------

  data_file = 'caiso_renewables_daily_2020-01-01_2020-12-31.csv'
  
# load libaries ------
  
  library(data.table)
  library(ggplot2)
  library(hrbrthemes)
  library(extrafont)

# load data ------
  
  dt_caiso = fread(here::here('data', data_file), header = T)
  
# get month column ------
  
  dt_caiso[, month := format(date, '%B')]
  
  cols = c('geothermal', 'biomass', 'biogas', 'small_hydro', 'wind_total', 'solar_pv', 'solar_thermal')
  dt_caiso[, paste0(cols, "_mean") := lapply(.SD, mean), .SDcols = cols, by = .(month)]
  
# convert integer columns to numeric ------
  
  dt_caiso[, solar_pv := as.numeric(as.character(solar_pv))]
  
# reorder month levels -----
  
  dt_caiso[, month := factor(month, levels = c('January', 'February', 'March', 'April', 'May', 'June', 'July',
                                               'August', 'September', 'October', 'November', 'December'))]
  
# ----------------------- PLOTS ------------------------ #
  
  # plot theme -------
  
    theme_line = theme_ipsum(base_family = 'Roboto Condensed',
                             grid = '', 
                             plot_title_size = 16, 
                             subtitle_size = 12,
                             axis_title_just = 'center',
                             axis_title_size = 12, 
                             axis_text_size = 12,
                             strip_text_size = 13)  +
      theme(plot.title = element_text(hjust = 0, face = 'bold'),
            plot.title.position = 'plot',
            plot.subtitle = element_text(hjust = 0),
            plot.caption = element_text(size = 10, color = '#5c5c5c', face = 'plain'),
            plot.margin = unit(c(1,1,1,1), 'lines'),
            axis.line.x = element_line(color = 'black', size = 0.3),
            axis.ticks.x = element_line(color = 'black', size = 0.3),
            axis.ticks.length.x = unit(0.2, 'cm'),
            axis.text.x = element_text(margin = margin(2, 0, 0, 0)))
  
  # plot: solar pv -------
  
    fig_solar = ggplot(dt_caiso, aes(x = solar_pv/1e3, fill = solar_pv_mean)) + 
      geom_density(alpha = 0.7, color = 'black', lwd = 0.1) + 
      labs(title = 'CAISO solar generation in 2020',
           subtitle = 'Distribution of daily solar PV generation by month. \nColor is average daily generation for that month, where darker red represents a higher average.',
           caption = 'Source: CAISO OASIS',
           x = 'Daily generation (GWh)',
           y = NULL) + 
      facet_wrap(~month, ncol = 1, strip.position = "left", dir = "v") +
      scale_fill_gradient(low = '#fee6ce', high = '#e6550d') +
      scale_x_continuous(expand = c(0,0)) +
      scale_y_continuous(expand = c(0,0)) + 
      theme_line +  
      theme(strip.text.y.left = element_text(angle = 0, hjust = 1, vjust = 0)) +
      theme(panel.spacing.y = unit(-4, "lines")) +
      theme(axis.text.y = element_blank()) +
      theme(legend.position = "none") +
      theme(plot.subtitle = element_text(margin=margin(0,0,-35,0)))
    # fig_solar
    
    ggsave(fig_solar,
           filename = file.path(here::here('figures'), 'plot-ridgeline-solar.pdf'),
           width = 6.8,
           height = 7,
           units = 'in', 
           device = 'pdf')
    
    embed_fonts(file.path(here::here('figures'), 'plot-ridgeline-solar.pdf'),
                outfile = file.path(here::here('figures'), 'plot-ridgeline-solar.pdf'))
    
  