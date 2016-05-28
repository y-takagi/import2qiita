# -*- coding: utf-8 -*-

#
# API-document.md
#
# [[ステータスコードについて|Api-status-code]]
# Api-status-code.md
#
# Qiita link
# [ステータスコードについて](URL)
#
# md.each do |md|
#   正規表現でpage_link_fileを元にmdの中身を書き換える
#

module ReplacePageLink
  def replace path
  end

  def foo s, file_name, url
    escape_file_name = Regexp.escape(file_name)
    reg = Regexp.new("\\[\\[(.+)\\|#{escape_file_name}\\]\\]")
    s.gsub(reg, "[\\1](#{url})")
  end
end
