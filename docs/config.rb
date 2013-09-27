###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
activate :automatic_image_sizes

# Reload the browser automatically whenever files change
#activate :livereload

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :css_dir, 'css'

set :js_dir, 'js'

set :images_dir, 'images'

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

ignore 'css/theme/template/*'
ignore 'css/theme/README.html'

activate :directory_indexes

activate :syntax #, :line_numbers => true


# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  activate :asset_hash

  # Use relative URLs
  activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end


module Haml::Filters::Graphviz
  include Haml::Filters::Base

  def render(text)
    text.sub!(/(\A\s*(?:di)?graph[^{]+{\s*$)/, "\\1\n   bgcolor=\"transparent\"")
    %Q[<script type="text/graphviz">#{text}</script>]
  end
end

module Haml::Filters::RubyCode
  include Middleman::Syntax::Helper
  include Haml::Filters::Base

  def render(text)
    code("ruby") { text.encode("UTF-8") }
  end

  def capture_html
    yield
  end

  def concat_content x
    x
  end
end