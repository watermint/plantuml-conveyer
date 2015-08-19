#!/usr/bin/ruby

class Conveyer
  def initialize dir
    @watch = dir
    @batch = 1

    ensure_plantuml
  end

  def ensure_plantuml
    @conveyer_home     = "#{ENV["HOME"]}/.plantuml-conveyer"
    @conveyer_plantuml = "#{@conveyer_home}/plantuml.jar"

    unless File.exist?(@conveyer_plantuml)
      download_plantuml
    end
  end

  def download_plantuml
    log '# Download PlantUML'
    url = 'http://sourceforge.net/projects/plantuml/files/plantuml.jar/download'
    command "mkdir -p #{@conveyer_home}"
    command "wget -O #{@conveyer_plantuml} #{url}"
  end

  def command commandline
    `#{commandline}`
  end

  def log log
    puts log
  end

  def process_file source
    puts "[#{@batch}] #{source}"
    command "java -Djava.awt.headless=true -jar #{@conveyer_plantuml} \"#{source}\""
    @batch += 1
  end

  def verify_file source
    image = source.sub(/plantuml$/, 'png')
    if File.exist?(image)
      if File.ctime(image) < File.ctime(source)
        process_file source
      end
    else
      process_file source
    end
  end

  def watch_entry entry
    if File.directory?(entry)
      watch_directory entry
    elsif entry.end_with?('.plantuml')
      verify_file entry
    end
  end

  def watch_directory dir
    Dir.entries(dir).delete_if {|e| e.start_with?('.') }.each do |e|
      watch_entry "#{dir}/#{e}"
    end
  end

  def start
    while true
      watch_directory @watch
      sleep 1
    end
  end
end

conveyer = Conveyer.new '.'
conveyer.start
