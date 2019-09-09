require 'html_checker'
require 'optparse'


options = {
  :html_file_path => './src',
  :eternal_link   => true,
  :with_out_css   => false,
}
parser = OptionParser.new.tap do |parser|
  parser.on('-e value', '--eternal-link value') {|value| options[:eternal_link] = (value.downcase == 'true')}
  parser.on('--without-css') {options[:with_out_css] = true}
end
parser.parse!(ARGV)
options[:html_file_path] = ARGV.first if ARGV.first

html_exit_code = HtmlChecker::HtmlChecker.new.execute(options[:html_file_path], options[:eternal_link])

css_exit_code = 0
css_exit_code = HtmlChecker::CssChecker.new.execute(options[:html_file_path]) unless options[:with_out_css]

exit_code = (html_exit_code != 0 || css_exit_code != 0) ? 1 : 0

exit exit_code
