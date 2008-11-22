require File.join(File.dirname(__FILE__), '..', 'spec_helper')

module Cache
  describe Finders do
    describe 'Cache Usage' do
      describe 'when the cache is populated' do
        describe '#find' do
          describe 'when given an id' do
            it 'does not use the database' do
              story = Story.create!
              mock(Story.connection).execute.never
              Story.find(story.id).should == story
            end
          end

          describe 'find(:first, ...)' do
            describe 'find(:first, :conditions => { :id => ?})' do
              it "does not use the database" do
                story = Story.create!
                mock(Story.connection).execute.never
                Story.find(:first, :conditions => { :id => story.id }).should == story
              end
            end

            describe "find(:first, :conditions => 'id = ?')" do
              it "does not use the database" do
                story = Story.create!
                mock(Story.connection).execute.never
                Story.find(:first, :conditions => "id = #{story.id}").should == story
                Story.find(:first, :conditions => "`stories`.id = #{story.id}").should == story
                Story.find(:first, :conditions => "`stories`.`id` = #{story.id}").should == story
              end
            end

            describe 'find(:first, :readonly => false) and any other options other than conditions are nil' do
              it "does not use the database" do
                story = Story.create!
                mock(Story.connection).execute.never
                Story.find(:first, :conditions => { :id => story.id }, :readonly => false, :limit => nil, :offset => nil, :joins => nil, :include => nil).should == story
              end
            end

            describe 'find(:first, :readonly => true)' do
              it "uses the database, not the cache" do
                story = Story.create!
                mock(Story).fetch_cache.never
                Story.find(:first, :conditions => { :id => story.id }, :readonly => true).should == story
              end
            end

            describe 'find(:first, :join => ...) or find(..., :include => ...)' do
              it "uses the database, not the cache" do
                story = Story.create!
                mock(Story).fetch_cache.never
                Story.find(:first, :conditions => { :id => story.id }, :joins => 'AS stories').should == story
                Story.find(:first, :conditions => { :id => story.id }, :include => :characters).should == story
              end
            end

            describe 'find(:first)' do
              it 'uses the database, not the cache' do
                mock(Story).fetch_cache.never
                Story.find(:first)
              end
            end

            describe 'find(:first, :conditions => { :id => ?, :other ...})' do
              it 'uses the database, not the cache' do
                story = Story.create!
                mock(Story).fetch_cache.never
                Story.find(:first, :conditions => { :id => story.id, :title => story.title }).should == story
              end
            end

            describe 'find(:first, :conditions => "...")' do
              describe 'on unindexed attributes' do
                it 'uses the database, not the cache' do
                  story = Story.create!
                  mock(Story).fetch_cache.never
                  Story.find(:first, :conditions => "type IS NULL")
                end
              end

              describe 'on indexed attributes' do
                describe 'when the attributes are integers' do
                  it 'does not use the database' do
                    story = Story.create!
                    mock(Story.connection).execute.never
                    Story.find(:first, :conditions => "`stories`.id = #{story.id}") \
                      .should == story
                  end
                end

                describe 'when the attributes are non-integers' do
                  it 'uses the database, not the cache' do
                    story = Story.create!(:title => "title")
                    mock(Story.connection).execute.never
                    Story.find(:first, :conditions => "`stories`.title = '#{story.title }'") \
                      .should == story
                  end
                end
              end

              describe 'find(:first, :conditions => [...])' do
                describe 'with one indexed attributes' do
                  it 'does not use the database' do
                    story = Story.create!
                    mock(Story.connection).execute.never
                    Story.find(:first, :conditions => ['id = ?', story.id]).should == story
                  end
                end

                describe 'with two attributes that match a combo-index' do
                  it 'does not use the database' do
                    story = Story.create!(:title => 'title')
                    mock(Story.connection).execute.never
                    Story.find(:first, :conditions => ['id = ? AND title = ?', story.id, story.title]).should == story
                  end
                end
              end
            end

            describe 'find(:first, :conditions => {...})' do
              it "does not use the database" do
                story = Story.create!(:title => "Sam")
                mock(Story.connection).execute.never
                Story.find(:first, :conditions => { :id => story.id, :title => story.title }).should == story
              end

              describe 'regardless of hash order' do
                it 'does not use the database' do
                  story = Story.create!(:title => "Sam")
                  mock(Story.connection).execute.never
                  Story.find(:first, :conditions => { :id => story.id, :title => story.title }).should == story
                  Story.find(:first, :conditions => { :title => story.title, :id => story.id }).should == story
                end
              end
            end
          end

          describe 'when there is a with_scope' do
            describe 'when the with_scope has conditions' do
              describe 'when the scope conditions is a string' do
                it "uses the database, not the cache" do
                  story = Story.create!
                  mock(Story).fetch_cache.never
                  Story.send :with_scope, :find => { :conditions => 'type IS NULL'} do
                    Story.find(:first, :conditions => { :id => story.id })
                  end
                end
              end

              describe 'when the find conditions is a string' do
                it "uses the database, not the cache" do
                  story = Story.create!
                  mock(Story).fetch_cache.never
                  Story.send :with_scope, :find => { :conditions => { :id => story.id }} do
                    Story.find(:first, :conditions => "type IS NULL")
                  end
                end
              end
            end

            describe 'has_many associations' do
              describe 'find(1)' do
                it "does not use the database" do
                  story = Story.create!
                  character = story.characters.create!
                  mock(Character.connection).execute.never
                  story.characters.find(character.id).should == character
                end
              end
              
              describe 'find(1, 2, ...)' do
                it "does not use the database" do
                  story = Story.create!
                  character1 = story.characters.create!
                  character2 = story.characters.create!
                  mock(Character.connection).execute.never
                  story.characters.find(character1.id, character2.id).should == [character1, character2]
                end
              end
              
              describe 'find_by_attr' do
                it "does not use the database" do
                  story = Story.create!
                  character = story.characters.create!
                  mock(Character.connection).execute.never
                  story.characters.find_by_id(character.id).should == character
                end
                
              end
            end
          end
        end

        describe 'find(:all)' do
          it "uses the database, not the cache" do
            character = Character.create!
            mock(Character).fetch_cache.never
            Character.find(:all).should == [character]
          end

          describe 'find(:all, :conditions => {...})' do
            it 'does not use the database' do
              story1 = Story.create!(:title => title = "title")
              story2 = Story.create!(:title => title)
              mock(Story.connection).execute.never
              Story.find(:all, :conditions => { :title => story1.title }).should == [story1, story2]
            end
          end
          
          describe 'find(:all, :limit => ..., :offset => ...)' do
            it "cached attributes should support limits and offsets" do
              character1 = Character.create!(:name => "Sam", :story_id => 1)
              character2 = Character.create!(:name => "Sam", :story_id => 1)
              character3 = Character.create!(:name => "Sam", :story_id => 1)
              mock(Character.connection).execute.never
        
              Character.find(:all, :conditions => { :name => character1.name, :story_id => character1.story_id }, :limit => 1).should == [character1]
              Character.find(:all, :conditions => { :name => character1.name, :story_id => character1.story_id }, :offset => 1).should == [character2, character3]
              Character.find(:all, :conditions => { :name => character1.name, :story_id => character1.story_id }, :limit => 1, :offset => 1).should == [character2]
            end
          end
        end

        describe 'find([1, 2, ...], :conditions => ...)' do
          it "uses the database, not the cache" do
            story1 = Story.create!
            story2 = Story.create!
            mock(Story).fetch_cache.never
            Story.find([story1.id, story2.id], :conditions => "stories.id <= #{story2.id } AND type IS NULL")
          end
        end

        describe '#find_by_attr' do
          describe 'on indexed attributes' do
            describe 'find_by_id(id)' do
              it "does not use the database" do
                story = Story.create!
                mock(Story.connection).execute.never
                Story.find_by_id(story.id).should == story
              end
            end

            describe 'find_by_title(title)' do
              it "should use the cache with find_by" do
                story1 = Story.create!(:title => 'title1')
                story2 = Story.create!(:title => 'title2')
                mock(Story.connection).execute.never
                Story.find_by_title('title1').should == story1
              end

            end
          end
        end

        describe "Single Table Inheritence" do
          describe '#find(:all, ...)' do
            it "does not use the database" do
              story, epic, oral = Story.create!(:title => title = 'foo'), Epic.create!(:title => title), Oral.create!(:title => title)
              mock(Story.connection).execute.never
              Story.find(:all, :conditions => { :title => title }).should == [story, epic, oral]
              Epic.find(:all, :conditions => { :title => title }).should == [epic, oral]
              Oral.find(:all, :conditions => { :title => title }).should == [oral]
            end
          end
        end
      end
    end
  end
end