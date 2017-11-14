require 'active_support'
require 'active_model'
require 'rexml/document'
require 'lazy_xml_model/version'
require 'lazy_xml_model/attribute_node'
require 'lazy_xml_model/element_node'
require 'lazy_xml_model/object_node'
require 'lazy_xml_model/array_node'
require 'lazy_xml_model/collection_proxy'
require 'lazy_xml_model/object_proxy'

module LazyXmlModel
  extend ActiveSupport::Concern

  included do
    include AttributeNode
    include ArrayNode
    include ElementNode
    include ObjectNode

    attr_writer :xml_doc
    attr_accessor :parent_xml_doc
    cattr_accessor :root_node

    #
    # Class Methods
    #
    def self.build_from_xml_str(xml_string)
      object = self.new
      object.xml_doc = REXML::Document.new(xml_string).root
      object
    end

    def self.build_from_xml_doc(xml_doc)
      object = self.new
      object.xml_doc = xml_doc
      object
    end
  end

  #
  # Instance Methods
  #
  def xml_doc
    @xml_doc ||= default_xml_doc
  end

  def to_xml
    output = ''
    REXML::Formatters::Pretty.new.write(xml_doc, output)
    output
  end

  def delete
    raise StandardError, 'You cannot delete the root node of a document!' if root_node?

    parent_xml_doc.delete(xml_doc)
  end

  private

  def default_xml_doc
    REXML::Document.new("<#{root_node_name}/>").root
  end

  def root_node_name
    self.root_node || self.class.name.demodulize.downcase
  end

  def root_node?
    parent_xml_doc.nil?
  end
end

