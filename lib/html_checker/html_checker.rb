require 'nokogiri'
require 'open-uri'
require 'erb'

class HtmlChecker::HtmlChecker
  include FileUtils

  attr_accessor :root_path, :exit_code, :html_ng_list

  def execute(root_path, eternal_link)
    self.html_ng_list = {a_tag: [], img_tag: [], link_tag: [], script_tag: [], input_tag: []}
    self.eternal_link = eternal_link
    p "start html checker"

    self.root_path = root_path
    self.exit_code = 0

    Dir::glob("#{root_path}/**/*.html").each do |html_file|

      html = File.open(html_file).read
      doc = Nokogiri::HTML.parse(html)

      # aタグのhref
      validate_html_link(html_file, doc, 'a', :href, html_ng_list[:a_tag])

      # imgタグのsrc
      validate_html_link(html_file, doc, 'img', :src, html_ng_list[:img_tag])

      # linkタグのsrc
      validate_html_link(html_file, doc, 'link', :src, html_ng_list[:link_tag])

      # scriptタグのsrc
      validate_html_link(html_file, doc, 'script', :src, html_ng_list[:script_tag])

      # inputタグのsrc
      validate_html_link(html_file, doc, 'input', :src, html_ng_list[:input_tag])
    end

    p "html check OK" if exit_code == 0
    
    result_data_path = File.join(root_path, 'result_data')
    FileUtils.mkdir_p(result_data_path) unless FileTest.exist?(result_data_path)
    
    File.open(File.join(result_data_path, "result_html_checker.html"),'w') do |file|
      erb_file = File.open(File.join(File.dirname(__FILE__), '..', 'contents', 'result_html_checker.html.erb')).read

      erb = ERB.new(erb_file)
      file.write erb.result(binding)
    end

    return exit_code
  end

  def validate_html_link(html_file, doc, tag_name, attribute_name, ng_list)

    href_html_set = Set.new
    doc.css(tag_name).each do |tag|

      next if tag[attribute_name].nil?

      href_html = replace_absolute_path(File::dirname(html_file), tag[attribute_name])

      next if href_html.nil? || href_html_set.include?(href_html)

      href_html_set.add(href_html)
      if !href_exist?(href_html, attribute_name == :href) 
        p "NG #{tag_name} #{attribute_name} #{html_file} => #{href_html}"
        ng_list << {file_name: html_file.gsub(root_path, ''), tag: tag_name, attribute: attribute_name, target: href_html.gsub(root_path, '')}
        self.exit_code = 1
      end
    end
  end

end
