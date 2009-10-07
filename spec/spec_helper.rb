begin
  RAILS_ROOT = File.expand_path(".") unless defined? RAILS_ROOT
  require RAILS_ROOT + '/spec/spec_helper'
rescue LoadError => error
  puts <<-EOS

    You need to install rspec in your Redmine project.
    Please execute the following code:
    
      gem install rspec-rails
      script/generate rspec

  EOS
  raise error
end

require File.join(File.dirname(__FILE__), "..", "init.rb")