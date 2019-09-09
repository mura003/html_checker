class HtmlChecker::CssChecker
  include FileUtils

  attr_accessor :root_path, :exit_code, :css_ng_list

  def execute(root_path)

    p "start css checker"

    self.root_path = root_path
    self.exit_code = 0
    self.css_ng_list = []

    css_url_set = Set.new
    Dir::glob("#{root_path}/**/*.css").each do |css_file|

      css = File.open(css_file).read
      css.scan(/url\((.+)\)/).each do |css_url|

        next if css_url.nil? || css_url_set.include?(css_url)
        css_url_set.add(css_url)

        url_path = replace_absolute_path(File::dirname(css_file), css_url[0])

        if !href_exist?(url_path) 
          p "NG #{css_file} => #{url_path}"
          self.css_ng_list << {file_name: css_file.gsub(root_path, ''), url: url_path}
          self.exit_code = 1
        end
      end
    end

    p "css check OK" if exit_code == 0

    result_data_path = File.join(root_path, 'result_data')
    FileUtils.mkdir_p(result_data_path) unless FileTest.exist?(result_data_path)

    File.open(File.join(result_data_path, "result_css_checker.html"),'w') do |file|
      erb_file = File.open(File.join(File.dirname(__FILE__), '..', 'contents', 'result_css_checker.html.erb')).read

      erb = ERB.new(erb_file)
      file.write erb.result(binding)
    end

    return exit_code
  end
end
