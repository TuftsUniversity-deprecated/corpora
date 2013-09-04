class Snippet

  include Hydra::ModelMixins::RightsMetadata
  include AttachedFiles

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
 # has_metadata "rightsMetadata", type: Hydra::Datastream::RightsMetadata

  def get_snippet_id

  end

  def to_solr(solr_doc=Hash.new, opts={})
    {'id' => id,
      'field_i_want_to_index_texts' => "blah"}
  end

end
