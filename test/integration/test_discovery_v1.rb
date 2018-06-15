# frozen_string_literal: true

require_relative("./../../lib/watson_developer_cloud.rb")
require("json")
require("minitest/autorun")
require("minitest/hooks/test")

# Integration tests for the Discovery V1 Service
class DiscoveryV1Test < Minitest::Test
  include Minitest::Hooks
  Minitest::Test.parallelize_me!
  attr_accessor :service, :environment_id, :collection_id
  def before_all
    @service = WatsonDeveloperCloud::DiscoveryV1.new(
      username: ENV["DISCOVERY_USERNAME"],
      password: ENV["DISCOVERY_PASSWORD"],
      version: "2018-03-05"
    )
    @environment_id = ENV["DISCOVERY_ENVIRONMENT_ID"]
    @collection_id = ENV["DISCOVERY_COLLECTION_ID"]
    @service.add_default_headers(
      headers: {
        "X-Watson-Learning-Opt-Out" => "1",
        "X-Watson-Test" => "1"
      }
    )
  end

  def test_environments
    envs = JSON.parse(@service.list_environments.body)
    refute(envs.nil?)
    env = @service.get_environment(
      environment_id: envs["environments"][0]["environment_id"]
    )
    refute(env.nil?)
    fields = @service.list_fields(
      environment_id: @environment_id,
      collection_ids: [@collection_id]
    )
    refute(fields.nil?)
  end

  def test_configurations
    configs = @service.list_configurations(
      environment_id: @environment_id
    ).body
    refute(configs.nil?)

    name = "test" + ("A".."Z").to_a.sample
    new_configuration_id = @service.create_configuration(
      environment_id: @environment_id,
      name: name,
      description: "creating new config for ruby sdk"
    ).body
    new_configuration_id = JSON.parse(new_configuration_id)["configuration_id"]
    refute(new_configuration_id.nil?)
    @service.get_configuration(
      environment_id: @environment_id,
      configuration_id: new_configuration_id
    )

    updated_config = @service.update_configuration(
      environment_id: @environment_id,
      configuration_id: new_configuration_id,
      name: "lala"
    ).body
    updated_config = JSON.parse(updated_config)
    assert_equal("lala", updated_config["name"])

    deleted_config = @service.delete_configuration(
      environment_id: @environment_id,
      configuration_id: new_configuration_id
    ).body
    deleted_config = JSON.parse(deleted_config)
    assert_equal("deleted", deleted_config["status"])
  end

  def test_collections_and_expansions
    name = "Example collection for ruby" + ("A".."Z").to_a.sample
    new_collection_id = @service.create_collection(
      environment_id: @environment_id,
      name: name,
      description: "Integration test for ruby sdk"
    ).body
    new_collection_id = JSON.parse(new_collection_id)["collection_id"]
    refute(new_collection_id.nil?)

    @service.get_collection(
      environment_id: @environment_id,
      collection_id: new_collection_id
    )
    updated_collection = @service.update_collection(
      environment_id: @environment_id,
      collection_id: new_collection_id,
      name: name,
      description: "Updating description"
    ).body
    updated_collection = JSON.parse(updated_collection)
    assert_equal("Updating description", updated_collection["description"])

    @service.create_expansions(
      environment_id: @environment_id,
      collection_id: new_collection_id,
      expansions: [
        {
          "input terms" => ["a"],
          "expanded_terms" => ["aa"]
        }
      ]
    )
    expansions = @service.list_expansions(
      environment_id: @environment_id,
      collection_id: new_collection_id
    ).body
    expansions = JSON.parse(expansions)
    refute(expansions["expansions"].nil?)

    @service.delete_expansions(
      environment_id: @environment_id,
      collection_id: new_collection_id
    )
    deleted_collection = @service.delete_collection(
      environment_id: @environment_id,
      collection_id: new_collection_id
    ).body
    deleted_collection = JSON.parse(deleted_collection)
    assert_equal("deleted", deleted_collection["status"])
  end

  # def test_thing
  #   response = @service.query(
  #     environment_id: @environment_id,
  #     collection_id: @collection_id
  #   ).body
  #   response = JSON.parse(response)
  #   response["results"].each do |id|
  #     service_response = @service.delete_document(
  #       environment_id: @environment_id,
  #       collection_id: @collection_id,
  #       document_id: id["id"]
  #     ).body
  #   end
  # end

  def test_documents
    add_doc = nil
    File.open(Dir.getwd + "/resources/simple.html") do |file_info|
      add_doc = @service.add_document(
        environment_id: @environment_id,
        collection_id: @collection_id,
        file: file_info
      ).body
    end
    add_doc = JSON.parse(add_doc)
    refute(add_doc["document_id"].nil?)

    doc_status = { "status" => "processing" }
    while doc_status["status"] == "processing"
      doc_status = @service.get_document_status(
        environment_id: @environment_id,
        collection_id: @collection_id,
        document_id: add_doc["document_id"]
      ).body
      doc_status = JSON.parse(doc_status)
    end
    assert_equal("available", doc_status["status"])

    update_doc = nil
    File.open(Dir.getwd + "/resources/simple.html") do |file_info|
      update_doc = @service.update_document(
        environment_id: @environment_id,
        collection_id: @collection_id,
        document_id: add_doc["document_id"],
        file: file_info,
        filename: "newname.html"
      ).body
    end
    refute(update_doc.nil?)

    doc_status = { "status" => "processing" }
    while doc_status["status"] == "processing"
      doc_status = @service.get_document_status(
        environment_id: @environment_id,
        collection_id: @collection_id,
        document_id: add_doc["document_id"]
      ).body
      doc_status = JSON.parse(doc_status)
    end
    assert_equal("available", doc_status["status"])

    delete_doc = @service.delete_document(
      environment_id: @environment_id,
      collection_id: @collection_id,
      document_id: add_doc["document_id"]
    ).body
    delete_doc = JSON.parse(delete_doc)
    assert_equal("deleted", delete_doc["status"])
  end

  def test_queries
    query_results = @service.query(
      environment_id: @environment_id,
      collection_id: @collection_id,
      filter: "extracted_metadata.sha1::9181d244*",
      return_fields: ["extracted_metadata.sha1"]
    ).body
    refute(query_results.nil?)
  end
end