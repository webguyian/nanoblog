begin
  require 'nanoc3/tasks'
rescue LoadError
  require 'rubygems'
  require 'stringex'
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
    post.puts "created_at: #{Time.now}"
    post.puts 'kind: article'
    post.puts 'publish: false'
    post.puts "---\n\n"
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
  system "nanoc co"
  # system "mv _site/blog/atom.html _site/blog/atom.xml"
end

desc "build and commit the website in the master branch"
task :build => :generate_all do
  require 'git'
  repo = Git.open('.')
  repo.branch("master").checkout
  (Dir["*"] - [site]).each { |f| rm_rf(f) }
  Dir["#{site}/*"].each {|f| mv(f, ".")}
  rm_rf(site)
  Dir["**/*"].each {|f| repo.add(f) }
  repo.status.deleted.each {|f, s| repo.remove(f)}
  message = ENV["MESSAGE"] || "Site updated at #{Time.now.utc}"
  repo.commit(message)
  repo.branch("source").checkout
end

desc "generate and deploy website"
task :deploy => :build do
  system "git push origin master"
end

desc "preview the site in a web browser"
multitask :preview => [:generate, :start_serve] do
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

def departialize(target)
  if (bn = File.basename(target))[0..0] == "_"
    target = file.join(file.dirname(target), bn[1..-1])
  end
  target
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


desc "Generate the whole site."
task :generate_all => [:generate, :sitemap]

task :build => :generate_all
