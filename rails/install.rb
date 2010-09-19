# Install hook code here
File.copy("public/stylesheets/semanticgap_date_time_form.css",
          File.join(Rails.root, "public", "stylesheets", "semanticgap_date_time_form.css"))

puts
puts "Remember to add the following to your layout:"
puts "  <%= stylesheet_link_tag 'semanticgap_date_time_form' %>"
puts
