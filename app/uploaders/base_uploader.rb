# frozen_string_literal: true

class BaseUploader < CarrierWave::Uploader::Base
  THUMB_IMAGE_EXTS = %w[.jpg .jpeg .gif .png]

  # 在 UpYun 或其他平台配置图片缩略图
  # http://docs.upyun.com/guide/#_12
  # Avatar
  # 固定宽度和高度
  # xs - 32x32
  # sm - 48x48
  # md - 96x96
  # lg - 192x192
  #
  # Photo
  # large - 1920x? - 限定宽度，高度自适应
  ALLOW_VERSIONS = %w[xs sm md lg large]

  def store_dir
    dir = model.class.to_s.underscore
    if Setting.upload_provider == "file"
      dir = "uploads/#{dir}"
    end
    dir
  end

  def extension_whitelist
    %w[jpg jpeg gif png svg]
  end

  def allow_thumb?(url)
    return false if url.nil?
    THUMB_IMAGE_EXTS.include?(File.extname(url))
  end

  def url(version_name = nil)
    @url ||= super({})
    return @url if version_name.blank?
    return @url unless allow_thumb?(@url)

    version_name = version_name.to_s
    unless version_name.in?(ALLOW_VERSIONS)
      raise "ImageUploader version_name:#{version_name} not allow."
    end

    case Setting.upload_provider
    when "aliyun"
      super(thumb: "?x-oss-process=image/#{aliyun_thumb_key(version_name)}")
    when "upyun"
      [@url, version_name].join("!")
    when "qiniu"
      super(style: qiniu_thumb_key(version_name))
    else
      [@url, version_name].join("!")
    end
  end

  private

    def aliyun_thumb_key(version_name)
      case version_name
      when "large" then "resize,w_1920/format,jpg/interlace,1"
      when "lg"    then "resize,w_192,h_192,m_fill/format,jpg/interlace,1"
      when "md"    then "resize,w_96,h_96,m_fill/format,jpg/interlace,1"
      when "sm"    then "resize,w_48,h_48,m_fill/format,jpg/interlace,1"
      when "xs"    then "resize,w_32,h_32,m_fill/format,jpg/interlace,1"
      else
        "resize,w_32,h_32,m_fill/format,jpg/interlace,1"
      end
    end

    def qiniu_thumb_key(version_name)
      case version_name
      when "large" then "imageView2/2/w/1920/q/100"
      when "lg"    then "imageView2/3/w/192/h/192/q/100"
      when "md"    then "imageView2/3/w/96/h/96/q/100"
      when "sm"    then "imageView2/3/w/48/h/48/q/100"
      when "xs"    then "imageView2/3/w/32/h/32/q/100"
      else
        "imageView2/3/w/32/h/32/q/100"
      end
    end
end
