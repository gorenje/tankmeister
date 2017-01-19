desc "compile scss templates"
task :generate_main_css do
  require 'sass'

  Pathname.glob("public/c/*.scss").each do |file|
    css_content = Sass::Engine.for_file(file, :syntax => :scss,
                                        :load_paths => ['public/c/_sass'],
                                        :style => :compressed).
      render
    File.write(file.sub_ext('.css'), css_content)
  end
end
