require 'pathname'
require 'qiita'

class ImportMd
  def initialize access_token, host=nil, team=nil
    raise "Need to set access token." unless access_token
    @client = Qiita::Client.new(access_token: access_token, host: host, team: team)
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
  end

  private
  def upload params={}
    @client.create_item(params)
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
    puts e
  end

  # Extract tags from directory name
  def parse_directory_name path
    dirname = path.basename.to_s
    dirname.split('.')
  end
end
