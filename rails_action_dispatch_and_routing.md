### polymorphic routes

http://api.rubyonrails.org/classes/ActionDispatch/Routing/PolymorphicRoutes.html


    = link_to 'Edit', edit_polymorphic_path([@contentable, @content])
    = link_to 'New',  new_polymorphic_path([@contentable, Content.new])
    = link_to 'index', polymorphic_path([@contentable, @content])
    = link_to 'index', polymorphic_path([@contentable, Content.new])

also can be achived with 

    = link_to 'edit', [:edit, @contentable, @content]


### url_for

    url_for(controller: :documents, action: :index)
