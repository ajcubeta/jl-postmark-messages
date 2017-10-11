module ApplicationHelper
  def link_with_current(label, path, controller_name, action_name, has_sub=false)
    if controller.class.to_s =~ controller_name
      if action_name
        if controller.action_name =~ action_name
          has_sub ? link_to(label, path, :class => "current has_sub") : link_to(label, path, :class => "current")
        else
          has_sub ? link_to(label, path, :class => "has_sub") : link_to(label, path)
        end
      else
        has_sub ? link_to(label, path, :class => "current has_sub") : link_to(label, path, :class => "current")
      end
    else
      has_sub ? link_to(label, path, :class => "has_sub") : link_to(label, path)
    end
  end
end
