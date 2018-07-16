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
  task :keys do
    has_all_keys = true
    keys = [
      ['OauthKey', 'PROD_CLIENT_KEY'],
      ['OauthSecret', 'PROD_CLIENT_SECRET'],
      ['Domain', 'PROD_DOMAIN'],
      ['SegmentKey', 'PROD_SEGMENT_KEY'],

      ['NinjaOauthKey', 'NINJA_CLIENT_KEY'],
      ['NinjaOauthSecret', 'NINJA_CLIENT_SECRET'],
      ['NinjaDomain', 'NINJA_DOMAIN'],

      ['Stage1OauthKey', 'STAGE1_CLIENT_KEY'],
      ['Stage1OauthSecret', 'STAGE1_CLIENT_SECRET'],
      ['Stage1Domain', 'STAGE1_DOMAIN'],

      ['Stage2OauthKey', 'STAGE2_CLIENT_KEY'],
      ['Stage2OauthSecret', 'STAGE2_CLIENT_SECRET'],
      ['Stage2Domain', 'STAGE2_DOMAIN'],

      ['RainbowOauthKey', 'RAINBOW_CLIENT_KEY'],
      ['RainbowOauthSecret', 'RAINBOW_CLIENT_SECRET'],
      ['RainbowDomain', 'RAINBOW_DOMAIN'],

      ['StagingSegmentKey', 'STAGING_SEGMENT_KEY'],

      ['TeamId', 'ELLO_TEAM_ID'],
      ['SodiumChloride', 'INVITE_FRIENDS_SALT'],
      ['NewRelicKey', 'NEW_RELIC_KEY'],
    ]
    keys.each do |name, env_name|
      has_all_keys = has_all_keys && check_env(env_name)
    end

    if has_all_keys
      keys.each do |name, env_name|
        set_key(name, env_name)
      end
    end
    sh "bundle exec pod install" if has_all_keys
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
