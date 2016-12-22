desc "Start a pry shell and load all gems"
task :shell  do
  require 'pry'
  Pry.editor = ENV['PRY_EDITOR'] || ENV['EDITOR'] || 'emacs'
  Pry.start
end
