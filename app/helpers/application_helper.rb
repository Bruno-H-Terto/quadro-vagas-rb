module ApplicationHelper
  def form_errors(object, attr)
    return unless object.errors[attr].any?

    safe_join(
      object.errors.full_messages_for(attr).map do |e|
        content_tag(:span, e, class: "text-red-500 text-xs block")
      end
    )
  end

  def form_error_message(object, attribute)
    if object.errors[attribute].any?
      content_tag :small, class: 'absolute flex justify-between w-full py-1 text-xs transition text-pink-500' do
        content_tag :span do
          object.errors.full_messages_for(attribute).join(", ")
        end
      end
    end
  end
end
