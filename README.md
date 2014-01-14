# Easel

Easel lets you easily bind RDF vocabulary definitions to ActiveModel instances, letting
you easily define your models in terms of RDF vocabularies and access
[RDF.rb](http://rdf.rubyforge.org/) representations of your models. This is in
contrast to the two common ways of working with RDF data in practice today:

1. Maintaining your data as 'pure' RDF via a project like
[RDF.rb](http://rdf.rubyforge.org/). This is great for exposing the power of
RDF but doesn't square with conventional Rails stacks.

2. Maintaining your data within a conventional Rails environment, and 'doing RDF' by exporting
XML that happens to look like RDF-XML. This is fine for exposing resources as
RDF, but passes over the great capabilities that RDF provides over and above
serialization.

Easel lets you live in between these two extremes. It helps you do this by doing
two things:

1. Providing a `bind_to` class method that lets you map your model's properties
to terms in any number of RDF vocabularies. After binding to, say,
the `DC` Vocabulary, the attributes of your model will be mapped to corresponding
properties defined in the `DC` vocabulary, including `#title`, `#author`, and
others.

2. Providing a `#to_rdf` method on instances of the model that converts all
properties defined by a bound vocabulary into an `RDF::Graph` object. This graph
object can then be serialized into any format you desire, queried directly, or
used for any other purpose within the RDF.rb universe.

## How do I use it?

Simply add a `bind_to` declaration in your ActiveModel class for each RDF vocabulary
you want to bind to. You can then call `#to_rdf` on any instances of that model:

    class Example < ActiveRecord::Base
      include Easel::Bindable

      bind_to RDF::DC, :only => :title
    end

    e = Example.new(:title => "Of Mice and Men")
    e.to_rdf #=> An RDF::Graph containing a triple describing a DC.title of "Of
    Mice and Men"

It's important to note that Easel does not create attributes on your models. Easel
expects that your models will have a corresponding attribute defined for each
property name in the vocabulary (or only those specified by the `:only` parameter,
if present). To aid in this for dynamically configurable document stores such as
Mongoid, `bind_to` will yield for each property in a vocabulary. For example, the
following code will create a Mongoid model with each property in `RDF::DC` defined
as a String:

    class Example
      include Easel::Bindable
      include Mongoid::Document

      bind_to RDF::DC do |property|
        field property, :type => String
      end
    end

## Getting fancy

By default, `bind_to` will create mappings for every property in the named
vocabulary. Easel provides some flexibility with this, via the following options:

* **Binding Specific Properties**: It's often the case that you only want to bind
  a few properties from a vocabulary into your model. Easel lets you do that by
  listing a set of properties names to bind, using the `:only` option:

        bind_to RDF::DC, :only => [:title]

  will create a mapping for _only_ the `title` property. `:only` may be
  specified as an `Array` or as a standalone symbol, in the case where only one
  attribute is to be mapped.
