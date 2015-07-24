# set the locations that we will look for changed files to determine whether to restart
set :assets_dependencies, %w(config/events.rb config/websocket_rails.rb)

class StartRequired < StandardError;
end

class RestartRequired < StandardError;
end

namespace :deploy do
  namespace :websocket_rails_server do

    def start_server
      execute(:rake, "websocket_rails:start_server")
    end

    def restart_server
      execute(:rake, "websocket_rails:stop_server")
      execute(:rake, "websocket_rails:start_server")
    end

    desc "Restart websocket-rails server"
    task :restart do
      on roles(:websocket_rails_server) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            begin
              # find the most recent release
              latest_release = capture(:ls, '-xr', releases_path).split[1]

              # start server if this is the first deploy
              raise StartRequired unless latest_release

              latest_release_path = releases_path.join(latest_release)

              # start server if the pid is not found
              execute(:ls, latest_release_path.join('tmp', 'pids', 'websocket_rails.pid')) rescue raise(StartRequired)

              # restart server if the controllers in events.rb is changed
              events = File.read(latest_release_path.join('config/events.rb'))
              controllers = events.gsub(/#.*?\n/, '').scan(/to.*?\s(.*?Controller)/).uniq.map{|a| a[0]}
              controllers.each do |controller|
                release = release_path.join('app', 'controllers', "#{controller}.rb")
                latest = latest_release_path.join('app', 'controllers', "#{controller}.rb")
              end

              fetch(:assets_dependencies).each do |dep|
                release = release_path.join(dep)
                latest = latest_release_path.join(dep)
    
                # skip if both directories/files do not exist
                next if [release, latest].map{|d| test "[ -e #{d} ]"}.uniq == [false]
                
                # execute raises if there is a diff
                execute(:diff, '-Nqr', release, latest) rescue raise(PrecompileRequired)
              end

              info("Skipping asset precompile, no asset diff found")

              # copy over all of the assets from the last release
              execute(:cp, '-r', latest_release_path.join('public', fetch(:assets_prefix)), release_path.join('public', fetch(:assets_prefix)))
            rescue StartRequired
              start_server
            rescue RestartRequired
              restart_server
            end
          end
        end
      end
    end
  end
end