# Easel

Easel lets you easily bind RDF vocabulary definitions to Mongoid models, letting
you easily define your models in terms of RDF vocabularies and access
[RDF.rb](http://rdf.rubyforge.org/) representations of your models. This is in
contrast to the two common ways of working with RDF data in practice today:

1. Maintaining your data as 'pure' RDF via a project like
[RDF.rb](http://rdf.rubyforge.org/). This is great for exposing the power of
RDF but doesn't square with conventional Mongoid / Rails stacks.

2. Maintaining your data within a conventional Rails environment, and 'doing RDF' by exporting
XML that happens to look like RDF-XML. This is fine for exposing resources as
RDF, but passes over the great capabilities that RDF provides over and above
serialization.

Easel lets you live in between these two extremes. It helps you do this by doing
two things:

1. Providing a `bind_to` class method that lets you define the fields on your
Mongoid model in terms of any number of RDF vocabularies. After binding to, say,
the `DC` Vocabulary, your model will have fields corresponding to all of the
properties defined in the `DC` vocabulary, including `#title`, `#author`, and
all others. These fields are normal Mongoid fields, and can be manipulated,
saved and queried just like any other field.

2. Providing a `#to_rdf` method on instances of the model that converts all
properties defined by a bound vocabulary into an RDF::Graph object. This graph
object can then be serialized into any format you desire, queried directly, or
used for any other purpose within the RDF.rb universe.

## How do I use it?

Simply add a `bind_to` declaration in your Mongoid class for each RDF vocabulary
you want to bind to. You can then call `#to_rdf` on any instances of that model:

    class Example
      include Mongoid::Document
      include Easel::Bindable

      bind_to RDF::DC
    end

    e = Example.new(:title => "Of Mice and Men")
    e.to_rdf #=> An RDF::Graph containing a triple describing a DC.title of "Of
    Mice and Men"

## To be done

We have a couple of features still to integrate. Next up will be:

1. The ability to instantiate models based on existing RDF data (a `#from_rdf`
method, essentially).
2. The ability to be able to more flexibly bind vocabularies onto models,
including property aliases.
