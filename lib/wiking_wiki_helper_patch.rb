require_dependency 'redmine/wiki_formatting/textile/helper'

module WikingWikiHelperPatch

    def self.prepended(base)
        base.prepend(ClassMethods)
        base.send(:prepend, InstanceMethods)
        base.class_eval do
            unloadable

        end
    end

    module ClassMethods
    end

    module InstanceMethods

        def heads_for_wiki_formatter
            super

            unless @wiking_heads_for_wiki_formatter_included
                content_for :header_tags do
                    if File.exists?(File.join(Rails.root, 'plugins/wiking/assets/help/', current_language.to_s.downcase, 'wiki_syntax.html'))
                        wiking_url = "#{Redmine::Utils.relative_url_root}/plugin_assets/wiking/help/#{current_language.to_s.downcase}/wiki_syntax.html"
                    else
                        wiking_url = "#{Redmine::Utils.relative_url_root}/plugin_assets/wiking/help/en/wiki_syntax.html"
                    end

                    mention_rule = Setting.plugin_wiking['mention_rule'].present? ?
                                   javascript_tag("jsToolBar.prototype.mention_rule = '#{escape_javascript(Setting.plugin_wiking['mention_rule'])}';") : ''.html_safe
                    jstoolbar_lang = File.exists?(File.join(Rails.root, "plugins/wiking/assets/javascripts/jstoolbar/lang/jstoolbar-#{current_language.to_s.downcase}.js")) ?
                                     javascript_include_tag("jstoolbar/lang/jstoolbar-#{current_language.to_s.downcase}", :plugin => 'wiking') : ''.html_safe

                    mention_rule + javascript_include_tag('wiking', :plugin => 'wiking') + jstoolbar_lang +
                    javascript_include_tag('jquery.textcomplete.min', :plugin => 'wiking') +
                    javascript_tag("jsToolBar.prototype.more_link = '#{escape_javascript(wiking_url)}';")
                end
                @wiking_heads_for_wiki_formatter_included = true
            end
        end

        def wikitoolbar_for(field_id, preview_url = preview_text_path)
            super(field_id, preview_url) +
            javascript_tag(render(:partial => 'autocomplete/wiking.js', :locals => { :field_id => field_id }))
        end

    end

end
