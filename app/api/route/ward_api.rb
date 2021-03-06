# frozen_string_literal: true

module Route
  class WardApi < Base
    desc "Returns ward boundaries and names as GeoJSON", security: [{}]
    paginate paginate_settings

    params do
      optional(:geo, type: RGeo::Geos::CAPIPointImpl, coerce_with: GeoCoerce,
                     desc: 'GeoJSON of the location of interest, e.g. {"type":"Point","coordinates":[0.11906,52.20792]}')
      optional(:bbox, type: RGeo::Cartesian::BoundingBox, coerce_with: BboxCoerce,
                      desc: 'Four comma-separated coordinates making up the boundary of interest, e.g. "0.11905,52.20791,0.11907,52.20793"')
      exactly_one_of :geo, :bbox
    end

    get :wards do
      scope = Ward.order_by_size.intersects(params[:geo] || params[:bbox].to_geometry)
      scope = paginate scope
      features = scope.map { |const| RGeo::GeoJSON::Feature.new(const.location, nil, name: const.name) }
      collection = RGeo::GeoJSON::EntityFactory.new.feature_collection(features)
      RGeo::GeoJSON.encode(collection)
    end
  end
end
