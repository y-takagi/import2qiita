require 'pathname'
require 'qiita'
require 'csv'
require 'replace_page_link'

class ImportMd
  include ReplacePageLink

  def initialize access_token, host
    @access_token = access_token
    @host = host
    @client = Qiita::Client.new(access_token: access_token, host: host)
  end

  def run full_path, tags=[]
    path = Pathname.new(full_path)
    if path.file?
      upload create_params(path, tags)
    elsif path.directory?
      tags = parse_directory_name(path) if tags.empty?
      path.each_child { |file| upload create_params(file, tags) }
    else
      raise "#{full_path} does not exist."
    end
    save_page_link_to_csv
  end

  private
  def upload params={}, page_link=true
    response = @client.create_item(params)
    if page_link
      body = response.body
      raise response unless body.has_key?("id")
      @link_pairs ||= []
      @link_pairs << [body["id"], body["title"]]
    end
  rescue => e
    puts "upload error: #{e}"
  end

  def create_params path, tags
    # Validate
    raise "#{path}: Not a file or markdown file." if !path.file? || path.extname != '.md'
    raise "#{path}: Tags is empty." if tags.empty?

    {
      body: File.open(path).read,
      title: path.basename('.md').to_s,
      tags: tags.map { |tag| { name: tag, versions: [] } },
      coediting: true,
    }
  rescue => e
    puts "create_params error: #{e}"
  end

  # Extract tags from directory name
  def parse_directory_name path
    dirname = path.basename.to_s
    dirname.split('.')
  end

  def save_page_link_to_csv
    return unless @link_pairs
    CSV.open("page_link.csv", "a") do |csv|
      csv << ["id", "file_name"]
      @link_pairs.each { |pair| csv << pair }
    end
    true
  end
end
