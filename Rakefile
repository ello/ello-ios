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

end
