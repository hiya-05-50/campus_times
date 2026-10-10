module PlacementsHelper
  def safe_external_link(url, options = {})
    return nil if url.blank?

    clean_url = url.to_s.strip
    return nil unless clean_url.match?(/\Ahttps?:\/\//i)

    link_to(clean_url, clean_url, options.merge(target: "_blank", rel: "noopener noreferrer"))
  end
end
