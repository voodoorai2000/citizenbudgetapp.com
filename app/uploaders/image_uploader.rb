# coding: utf-8
require 'carrierwave/processing/mime_types'

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes

  process :set_content_type

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  version :large do
    process :resize_to_limit => [940, 200]
    process :set_width_and_height
  end
  version :medium do
    process :resize_to_limit => [470, 100]
  end
  version :square do
    process :resize_and_pad => [72, 72]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  # https://github.com/jnicklas/carrierwave/wiki/How-to:-Get-version-image-dimensions
  def set_width_and_height
    if @file && set_width_and_height?
      image = ::Magick::Image.read(@file.file).first
      model.send(width_method, image.columns)
      model.send(height_method, image.rows)
    end
  end

  def set_width_and_height?
    model && model.respond_to?(width_method) && model.respond_to?(height_method)
  end

  def width_method
    @width_method ||= "#{mounted_as}_width=".to_sym
  end

  def height_method
    @height_method ||= "#{mounted_as}_height=".to_sym
  end
end
