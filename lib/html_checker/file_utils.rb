module FileUtils

  def self.included(klass)
    klass.class_eval do 
      attr_accessor :eternal_link
    end
    @eternal_link = true
  end

  def replace_absolute_path(path, file_path)
    return nil if file_path.nil? || file_path.index('#') == 0
    return file_path if file_path.index('http://') == 0 || file_path.index('https://') == 0

    if file_path.index('/') == 0
      # 絶対パスと判断
      "#{self.root_path}#{file_path}"
    else
      # 相対パスと判断
      "#{path}/#{file_path}"
    end
  end
  
  def href_exist?(href, directory_index=false)
    if href.index('http://') == 0 || href.index('https://') == 0

      return true unless @eternal_link

      # ステータスコードを調べる
      begin
        open(href) do | f |
          http_status_code = f.status[0]
          return true
        end
      rescue => e
        return false
      end
    else
      # ファイルの存在を調べる
      href_rm_param = href.gsub(/(#.+|\?.+)/, '')
      if directory_index
        FileTest.file?(href_rm_param) || FileTest.file?(File.join(href_rm_param, 'index.html')) || FileTest.file?(File.join(href_rm_param, 'index.htm'))
      else
        FileTest.file?(href_rm_param)
      end
    end
  end
end
