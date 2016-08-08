# encoding: utf-8
# Copyright (c) 2016 Nathan Currier

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module Jekyll
  class AutoIndexPage < Page
    def initialize(site, dir)
      @site = site
      @base = site.source
      @dir = dir
      @name = 'index.html'
      @path = File.join(*[@base, @dir, @name].compact)

      @files = []

      process(@name)
      read_yaml(__dir__, 'template.html')
    end

    attr_accessor :files

    def read_yaml(base, name, opts = {})
      path, @path = @path, File.join(base, name)
      super
      @path = path
    end

    def prepare
      base_path = File.join(*[@base, @dir].compact)

      self.data['indexed'] =
        files.sort.map do |indexed|
          path = File.join(base_path, indexed)
          modified = File.stat(path).mtime.utc.strftime('%d-%b-%Y %H:%M:%S UTC')
          size = File.directory?(path) ? '-' : size_to_human(File.size(path))
          [ indexed, modified, size ]
        end

      self.data['path'] = @dir
      self.data['parent'] = File.dirname(@dir)
    end

    private

    SizeQuantities = [:B, :KiB, :MiB, :GiB, :TiB, :PiB, :EiB, :ZiB, :YiB]
    def size_to_human(size, quantity = SizeQuantities)
      if size >= 1024.0
        size_to_human(size / 1024.0, quantity.slice(1..-1))
      else
        "#{size.to_i == size ? size.to_i : format('%0.2f', size)} #{quantity.first}"
      end
    end
  end
end
