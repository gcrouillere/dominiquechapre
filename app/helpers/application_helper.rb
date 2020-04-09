module ApplicationHelper

  def destroy_admin_user_session_path
    return "/#{ENV['MODEL']}"
  end

  def photo_update(variable, top, right, bottom, left, classe, texte)
    @variable = variable.to_sym
    @top = top
    @right = right
    @bottom = bottom
    @left = left
    @classe = classe
    @texte = texte
    render partial: "shared/photo_update"
  end

  def article_typing_quill(article_name)
    @article = Article.find_by(name: article_name) || Article.new(id: -1, name: article_name, content: " ")
    return @article
  end

  def facebook_share_id(facebookid)
    @facebookid = facebookid
    render partial: "shared/socialbuttons"
  end

  def periodic_stat(duration)
    duration < 31 ? @text_duration = "#{duration} jours" : @text_duration = "#{duration / 30} mois"
    @duration = duration
    render partial: "admin/orders/stat_template"
  end

end
