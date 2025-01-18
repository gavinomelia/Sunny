class ChartGenerator
  BASE_URL = "https://image-charts.com/chart"

  def initialize(forecast)
    @forecast = forecast
  end

  def generate
    "#{BASE_URL}?#{query_params.to_query}"
  end

  private

  def query_params
    {
      chbh: 'a',
      chbr: '10',
      chco: 'fdb45c,1869b7',
      chd: "t:#{max_temps}|#{min_temps}",
      chds: '-20,120',
      chm: 'N,000000,0,,10|N,000000,1,,10',
      chma: '0,0,10,10',
      chs: '900x350',
      cht: 'bvg',
      chxs: '0,000000,12,0,_,000000|1,000000,12,0,_',
      chxt: 'x',
      chxl: "0:|#{formatted_dates.join('|')}|1"
    }
  end

  def max_temps
    @forecast['daily']['temperature_2m_max'].join(',')
  end

  def min_temps
    @forecast['daily']['temperature_2m_min'].join(',')
  end

  def formatted_dates
    @forecast['daily']['time'].map { |date| Date.parse(date).strftime('%b %d') }
  end
end

