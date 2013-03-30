begin
  require 'nanoc3/tasks'
  require 'stringex'
  require 'rubygems'
rescue LoadError
end


def ok_failed(condition)
  if (condition)
    puts "OK"
  else
    puts "FAILED"
  end
end

port = "3000"
site = "output"
current_date = Time.now.strftime("%Y-%m-%d")

desc "Create a new post"
task :new_post, :title do |t, args|
  mkdir_p './content/blog'
  args.with_defaults(:title => 'New Post')
  title = args.title
  filename = "./content/blog/#{title.to_url}.md"

  if File.exist?(filename)
    abort('rake aborted!') if ask("#{filename} already exists. Want to overwrite?", ['y','n']) == 'n'
  end

  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts '---'
    post.puts "title: \"#{title}\""
    post.puts "created_at: \"#{Time.now}\""
    post.puts 'kind: article'
    post.puts 'publish: false'
    post.puts "---\n\n"
  end
end

  desc "start up an instance of server on the output files"
  task :start_server do
      print "Starting server..."
      ok_failed system("nanoc view")
  end

  desc "stop all instances of server"
  task :stop_server do
    pid = `ps auxw | awk '/bin\\/serve\\ #{port}/ { print $2 }'`.strip
    if pid.empty?
      puts "Server is not running"
    else
      print "Stoping server..."
      ok_failed system("kill -9 #{pid}")
    end
  end

desc "remove files in output directory"
task :clean do
  puts "Removing output..."
  Dir["#{site}/*"].each { |f| rm_rf(f) }
end

desc "generate website in output directory"
task :generate => :clean do
  puts "Generating website..."
  system "nanoc compile"
  # system "mv _site/blog/atom.html _site/blog/atom.xml"
end

desc "build and commit the website in the master branch"
task :commit => :generate_all do
  require 'git'
  repo = Git.open('.')
  repo.branch("master").checkout
  (Dir["*"] - [site]).each { |f| rm_rf(f) }
  Dir["#{site}/*"].each {|f| mv(f, ".")}
  rm_rf(site)
  Dir["**/*"].each {|f| repo.add(f) }
  repo.status.deleted.each {|f, s| repo.remove(f)}
  message = ENV["MESSAGE"] || "Site updated at #{Time.now}"
  repo.commit(message)
  repo.branch("gh-pages").checkout
end

desc "generate and deploy website"
task :deploy => :build do
  system "git push origin master"
end

desc "preview the site in a web browser"
multitask :preview => [:generate, :start_server] do
  system "open http://localhost:#{port}/"
end

def rebuild_site(relative)
  puts ">>> Change Detected to: #{relative} <<<"
  Rake::Task["generate"].execute
  puts '>>> Update Complete <<<'
end

desc "Watch the site and regenerate when it changes"
task :watch do
  require 'fssm'
  puts ">>> Watching for Changes <<<"
  FSSM.monitor("#{File.dirname(__FILE__)}/content", '**/*') do
    update {|base, relative| rebuild_site(relative)}
    delete {|base, relative| rebuild_site(relative)}
    create {|base, relative| rebuild_site(relative)}
  end
end

desc "Build an XML sitemap of all html files."
task :sitemap => :generate do
  html_files = FileList.new("#{site}/**/*.html").map{|f| f[(site.size)..-1]}.map do |f|
    if f =~ /index.html$/
      f[0..(-("index.html".size + 1))]
    else
      f
    end
  end.sort_by{|f| f.size}
  open("#{site}/sitemap.xml", 'w') do |sitemap|
    sitemap.puts %Q{<?xml version="1.0" encoding="UTF-8"?>}
    sitemap.puts %Q{<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">}
    html_files.each do |f|
      priority = case f
      when %r{^/$}
        1.0
      when %r{^/blog}
        0.9
      when %r{^/featured/$}
        0.7
      else
        0.8
      end
      sitemap.puts %Q{  <url>}
      sitemap.puts %Q{    <loc>http://webguyian.com#{f}</loc>}
      sitemap.puts %Q{    <lastmod>#{current_date}</lastmod>}
      sitemap.puts %Q{    <changefreq>weekly</changefreq>}
      sitemap.puts %Q{    <priority>#{priority}</priority>}
      sitemap.puts %Q{  </url>}
    end
    sitemap.puts %Q{</urlset>}
    puts "Created #{site}/sitemap.xml"
  end
end

  JAR = "~/Resources/lib/yuicompressor/yuicompressor.jar"
  CSS_PATH = "~/Projects/nanoc/blog/content/css/"

  def minify(files)
    files.each do |file|
      next if file =~ /\.min\.(js|css)/
      
      minfile = file.sub(/\.js$/, ".min.js").sub(/\.css$/, ".min.css")

      cmd = "java -jar #{JAR} #{file} -o #{minfile}"
      puts cmd
      ret = system(cmd)
      raise "Minification failed for #{file}" if !ret
    end
  end

  desc "minify"
  task :minify => [:minify_js, :minify_css]

  desc "minify javascript"
  task :minify_js do
    minify(FileList['content/js/**/*.js'])
  end

  desc "minify css"
  task :minify_css do
    minify(FileList['content/css/**/*.css'])
  end


  desc "combine and minify css"
  task :compress_css do
    puts system("if [ -e ./content/css/style.min.css ]; then rm ./content/css/style.min.css; fi")
    puts ">>> Combining CSS files... <<<"
    puts system("cat #{CSS_PATH}*.css > #{CSS_PATH}style.min.css")
    puts system("java -jar #{JAR} ./content/css/style.min.css -o ./content/css/style.min.css;")
    puts ">>> CSS successfully minified! <<<"
  end

desc "Generate the whole site."
task :generate_all => [:compress_css, :generate, :sitemap]

task :build => :generate_all
