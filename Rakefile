require 'dotenv'
require 'dotenv/tasks'
require 'json'

Dotenv.load

namespace :generate do

  desc 'Generates strings file'
  task :strings do
    sh "find Sources -name '*.swift' | xargs genstrings -o ."
  end

  desc 'Sets cocoapods-keys for the app pointed at the staging server.'
  task :staging_keys do
    has_key = set_key('OauthKey', 'STAGING_CLIENT_KEY')
    has_key = set_key('OauthSecret', 'STAGING_CLIENT_SECRET') if has_key
    has_key = set_key('TeamId', 'ELLO_TEAM_ID') if has_key
    has_key = set_key('Domain', 'STAGING_DOMAIN') if has_key
    has_key = set_key('HttpProtocol', 'STAGING_HTTP_PROTOCOL') if has_key
    has_key = set_key('SodiumChloride', 'INVITE_FRIENDS_SALT') if has_key
    has_key = set_key('CrashlyticsKey', 'CRASHLYTICS_KEY') if has_key
    has_key = set_key('SegmentKey', 'SEGMENT_KEY') if has_key
    has_key = set_key('ConversionId', 'CONVERSION_ID') if has_key
    has_key = set_key('ConversionLabel', 'CONVERSION_LABEL') if has_key
    sh "bundle exec pod install" if has_key
  end

  desc 'Sets cocoapods-keys for the app pointed at the production server.'
  task :prod_keys do
    has_key = set_key('OauthKey', 'PROD_CLIENT_KEY')
    has_key = set_key('OauthSecret', 'PROD_CLIENT_SECRET') if has_key
    has_key = set_key('TeamId', 'ELLO_TEAM_ID') if has_key
    has_key = set_key('Domain', 'PROD_DOMAIN') if has_key
    has_key = set_key('HttpProtocol', 'PROD_HTTP_PROTOCOL') if has_key
    has_key = set_key('SodiumChloride', 'INVITE_FRIENDS_SALT') if has_key
    has_key = set_key('CrashlyticsKey', 'CRASHLYTICS_KEY') if has_key
    has_key = set_key('SegmentKey', 'SEGMENT_KEY') if has_key
    has_key = set_key('ConversionId', 'CONVERSION_ID') if has_key
    has_key = set_key('ConversionLabel', 'CONVERSION_LABEL') if has_key
    sh "bundle exec pod install" if has_key
  end

  desc 'Sets cocoapods-keys for the app pointed at the local development server.'
  task :local_keys do
    has_key = set_key('OauthKey', 'LOCAL_CLIENT_KEY')
    has_key = set_key('OauthSecret', 'LOCAL_CLIENT_SECRET') if has_key
    has_key = set_key('TeamId', 'ELLO_TEAM_ID') if has_key
    has_key = set_key('Domain', 'LOCAL_DOMAIN') if has_key
    has_key = set_key('SodiumChloride', 'INVITE_FRIENDS_SALT') if has_key
    has_key = set_key('CrashlyticsKey', 'CRASHLYTICS_KEY') if has_key
    has_key = set_key('SegmentKey', 'SEGMENT_KEY') if has_key
    has_key = set_key('ConversionId', 'CONVERSION_ID') if has_key
    has_key = set_key('ConversionLabel', 'CONVERSION_LABEL') if has_key
    sh "bundle exec pod install" if has_key
  end

  def set_key(key, env_var)
    return false unless check_env(env_var)
    sh "bundle exec pod keys set #{key} #{ENV[env_var]} Ello"
    return true
  end

  def check_env(env_var)
    return true if ENV[env_var]
    puts "You must have #{env_var} defined in your .env file to complete this task."
    return false
  end

  desc 'Pull down latest simulated responses from staging'
  task :responses do
    return false unless check_env('GITHUB_API_TOKEN') && check_env('STAGING_HTTP_PROTOCOL') && check_env('STAGING_DOMAIN')
    index = `curl -H 'Authorization: token #{ENV['GITHUB_API_TOKEN']}' 'https://raw.githubusercontent.com/ello/ello/master/docs/api/index.json'`
    json = JSON.parse(index)
    json["resources"].each do |resource|
      resource['examples'].each do |example|
        link = example['link']
        filename_arr = link.split('/')
        if filename_arr.length > 1
          filename = "#{filename_arr.first}_#{filename_arr.last}".gsub('-', '')
          filename += '.json' unless filename.match(/\.json$/)
          write_json(link, filename)
        end
      end
    end
    sh 'git ls-files --others --exclude-standard'
    puts 'Don\'t forget to add untracked resource files to Xcode!!!!!!!!!!!!!!!'
  end

  def write_json(path, filename = nil)
    puts "Getting file: #{path} for filename: #{filename}"
    path = "#{ENV['STAGING_HTTP_PROTOCOL']}://#{ENV['STAGING_DOMAIN']}/api/docs/simulate/#{path}"
    pretty_json = `curl '#{path}' | python -m json.tool`
    File.open("Resources/StubbedResponses/#{filename}", 'w') {|f| f.write pretty_json }
  end

end
