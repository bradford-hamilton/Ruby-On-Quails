# frozen_string_literal: true

Quails.application.routes.draw do
  get "/quails/active_storage/blobs/:signed_id/*filename" => "active_storage/blobs#show", as: :quails_service_blob

  direct :quails_blob do |blob|
    route_for(:quails_service_blob, blob.signed_id, blob.filename)
  end

  resolve("ActiveStorage::Blob")       { |blob| route_for(:quails_blob, blob) }
  resolve("ActiveStorage::Attachment") { |attachment| route_for(:quails_blob, attachment.blob) }


  get "/quails/active_storage/variants/:signed_blob_id/:variation_key/*filename" => "active_storage/variants#show", as: :quails_blob_variation

  direct :quails_variant do |variant|
    signed_blob_id = variant.blob.signed_id
    variation_key  = variant.variation.key
    filename       = variant.blob.filename

    route_for(:quails_blob_variation, signed_blob_id, variation_key, filename)
  end

  resolve("ActiveStorage::Variant") { |variant| route_for(:quails_variant, variant) }


  get  "/quails/active_storage/disk/:encoded_key/*filename" => "active_storage/disk#show", as: :quails_disk_service
  put  "/quails/active_storage/disk/:encoded_token" => "active_storage/disk#update", as: :update_quails_disk_service
  post "/quails/active_storage/direct_uploads" => "active_storage/direct_uploads#create", as: :quails_direct_uploads
end
