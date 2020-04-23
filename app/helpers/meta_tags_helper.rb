module MetaTagsHelper
  def meta_title
    content_for?(:title_tag) ? content_for(:title_tag) : "Les créations textiles uniques par Dominique Chapre"
  end

  def meta_product_name
    content_for?(:meta_product_name) ? content_for(:meta_product_name) : "Les créations textiles uniques par Dominique Chapre - vente de produits de l'artisanat"
  end

  def meta_description
    description = "Découvrez toutes les créations textiles : chapeaux, foulards, chemises en teintures naturelles, en vente dans la boutique. Vous pouvez également réserver un stage pour vous initier où vous perfectionner dans cet artisanat d'art unique."
    content_for?(:description) ? content_for(:description) : description
  end

  def meta_image
    meta_image = (content_for?(:meta_image) ? content_for(:meta_image).strip : image_path(ENV['HOMEPIC']))
    # little twist to make it work equally with an asset or a url
    meta_image.starts_with?("http") ? meta_image : image_url(meta_image)
  end

  def meta_no_index
    content_for(:noindex) if content_for?(:noindex)
  end
end

