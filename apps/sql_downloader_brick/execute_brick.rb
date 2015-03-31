# encoding: utf-8

module GoodData::Bricks
  class ExecuteBrick < GoodData::Bricks::Brick
    def call(params)
      logger = params['GDC_LOGGER']
      metadata = params["metadata_wrapper"]
      downloader = params["sql_downloader_wrapper"]
      # raise Exception, "The schedule parameters must contain ID of the downloader" if !params.include?("ID")
      metadata.set_source_context(params["ID"], {}, downloader)
      downloader.connect
      entities = metadata.get_downloader_entities_ids
      entities.each do |entity|
        downloader.load_metadata(entity)
        downloader.download_entity_data(entity)
      end
    end
  end
end
