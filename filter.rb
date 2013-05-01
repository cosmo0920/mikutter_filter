#!/usr/bin/env ruby -Ku
# -*- coding: utf-8 -*-
Plugin.create(:filter) do
  
  command(:filter_mute_client_add,
          name: "このクライアントをミュートする",
          condition: Plugin::Command[:CanReplyAll],
          visible: true,
          role: :timeline ) do |m|
    m.messages.map do |msg|
      tmp=UserConfig[:filter_mute_kind_client].melt
      tmp << msg[:source]
      UserConfig[:filter_mute_kind_client]=tmp
    end
  end
  
  filter_show_filter do |msgs|
    mute_words = (UserConfig[:filter_mute_kind_client] || []).select{|m|!m.empty?}
    if mute_words
      msgs = msgs.select{ |m|
        if m.retweet?
          not (UserConfig[:filter_mute_kind_client] || []).any?{ |word|
            word.to_s.include?(m.retweet_source[:source]) if m.retweet_source[:source] != nil
          }
          not (UserConfig[:filter_mute_kind_client] || []).any?{ |word|
            word.to_s.include?(m[:source]) if m[:source] != nil
          }
        else
          not (UserConfig[:filter_mute_kind_client] || []).any?{ |word|
            word.to_s.include?(m[:source]) if m[:source] != nil
          }
        end
      }
    end
    [msgs]
  end

  filter_show_filter do |msgs|
    mute_words = (UserConfig[:filter_mute_word] || []).select{|m|!m.empty?}
    if mute_words
      msgs = msgs.select{ |m|
        not (UserConfig[:filter_mute_word] || []).any?{ |word|
          m.to_s.include?(word)
        }
      }
    end
    [msgs]
  end

  settings "ミュート" do
    settings "フィルタする「種類」\n※設定する前に受信したツイートに対しては動きません" do
      multi "クライアント", :filter_mute_kind_client
      multi "単語", :filter_mute_word
    end
  end

end
