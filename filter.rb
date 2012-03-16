#!/usr/bin/env ruby -Ku
# -*- coding: utf-8 -*-
Plugin.create(:cilent_filter) do
  exclude_client = UserConfig[:filter_mute_kind_client]
  if exclude_client.is_a? Array then
    filter_show_filter do |msgs|
      msgs = msgs.select{ |m|
        not exclude_client.any?{ |word|
          word.to_s.include?(m[:source]) if m[:source] != nil
        }
      }
      [msgs]
    end
  end
end

Plugin.create(:mute_word) do
  exclude_word = UserConfig[:filter_mute_word]
  if exclude_word.is_a? Array then
    filter_show_filter do |msgs|
      msgs = msgs.select{ |m|
        not exclude_word.any?{ |word| 
          m.to_s.include?(word)
        } 
      }
      [msgs]
    end
  end
end

Plugin.create :filter do
  settings "ミュート" do
    settings "フィルタする「種類」\n※設定は再起動後に有効になります" do
      multi "クライアント", :filter_mute_kind_client
      multi "単語", :filter_mute_word
    end
  end
end
