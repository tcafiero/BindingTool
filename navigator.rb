class Navigator
	protected
	def initialize(level)
		@level=level
	end
	def element()

	end
	def attribute(name, value)

	end
	def endattribute()

	end
	def endelement()

	end
	def close()

	end

	def dive(item)
		
	end
	
	public
	def iterate (xpath=nil)
		@level.elements.each(xpath) {|item|
				self.element()
				item.attributes.each {|name, value|
					self.attribute(name, value)
					}
				self.endattribute()
				self.dive(item)
				self.endelement()
		}
	end
end
