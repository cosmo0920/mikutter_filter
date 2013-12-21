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
            word.to_s == m.retweet_source[:source] if m.retweet_source[:source] != nil
          }
        else
          not (UserConfig[:filter_mute_kind_client] || []).any?{ |word|
            word.to_s == m[:source] if m[:source] != nil
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

  # mute url
  filter_show_filter do |msgs|
    mute_words = (UserConfig[:filter_mute_url] || []).reject{|m|m.empty?}
    msgs = msgs.reject do |m|
      if m.system? then
        false
      else
        m[:entities][:urls].map{|u| u[:expanded_url]}.any? do |url|
          mute_words.any?{|w| url.include?(w)}
        end
      end
    end
    [msgs]
  end

  settings "ミュート" do
    settings "フィルタする「種類」\n※設定する前に受信したツイートに対しては動きません" do
      multi "クライアント", :filter_mute_kind_client
      multi "単語", :filter_mute_word
      multi "URL", :filter_mute_url
    end
  end

end
