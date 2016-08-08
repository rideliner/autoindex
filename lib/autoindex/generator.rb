# encoding: utf-8
# Copyright (c) 2016 Nathan Currier

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require 'autoindex/page'

module Jekyll
  class AutoIndexGenerator < Generator
    def generate(site)
      tree = index_tree(site)
      site.static_files.each { |page| register_files(page, tree) }
      add_indices(site, tree.values)
    end

    def index_tree(site)
      Hash.new do |h, k|
        h[k] = AutoIndexPage.new(site, k)
      end
    end

    def register_files(page, tree)
      path = File.dirname(page.relative_path)
      tree[path].files << File.basename(page.relative_path)

      until path == '/'
        dir = File.basename(path)
        path = File.dirname(path)
        tree[path].files << (dir + '/')
      end
    end

    def add_indices(site, indices)
      indices.select! do |index|
        site.pages.none? { |page| page.relative_path == index.relative_path }
      end
      indices.each(&:prepare)
      site.pages += indices
    end
  end
end
