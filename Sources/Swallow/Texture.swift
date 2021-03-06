//
//  Texture.swift
//  Swallow
//
//  Created by Alsey Coleman Miller on 1/23/16.
//  Copyright © 2016 PureSwift. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import OpenGLES
#endif

/// Represents a texture, an in-memory representation of an image in a compatible format the 
/// graphics processor can process.
///
/// Allows to create OpenGL textures from image files, text (font rendering) and raw data.
///
/// - Note: Be aware that the content of the generated texture will be upside-down! This is an OpenGL oddity.
public struct Texture {
    
    public let name: GLuint
    
    public let pixelFormat: PixelFormat
    
    /// Size in pixels.
    public let dataSize: (width: UInt, height: UInt)
    
    /// Content size of the texture in pixels.
    public let pixelContentSize: Size
    
    public let premultipliedAlpha: Bool
    
    /// Content size of the texture in points.
    public var contentSize: Size {
        
        var size = Size()
        
        size.width = pixelContentSize.width / contentScale
        
        size.height = pixelContentSize.height / contentScale
        
        return size
    }
    
    public var contentScale: Float
    
    // MARK: - Initialization
    
    public init(data: [UInt8], pixelFormat: PixelFormat = PixelFormat(), dataSize: (width: UInt, height: UInt), pixelContentSize: Size, contentScale: Float) {
        
        // FIXME: 32 bits or POT textures uses UNPACK of 4 (is this correct ??? )
        if pixelFormat == .RGBA8888 || pixelFormat == .BGRA8888 || (dataSize.width.nextPowerOfTwo == dataSize.width && dataSize.height.nextPowerOfTwo == dataSize.height) {
            
            glPixelStorei(GLenum(GL_UNPACK_ALIGNMENT), 4)
        
        } else {
            
            glPixelStorei(GLenum(GL_UNPACK_ALIGNMENT), 1)
        }
        
        var name: GLuint = 0
        
        glGenTextures(1, &name)
        glBindTexture(GLenum(GL_TEXTURE_2D), name)
        
        assert(name != 0, "Could not create OpenGL texture")
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GLint(GL_LINEAR))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GLint(GL_LINEAR))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLint(GL_CLAMP_TO_EDGE))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLint(GL_CLAMP_TO_EDGE))
        
        // Specify OpenGL texture image
        
        let glPixelFormat = pixelFormat.glTexImage2D
        
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, glPixelFormat.internalFormat, GLsizei(dataSize.width), GLsizei(dataSize.height), 0, glPixelFormat.format, glPixelFormat.type, data)
        
        // Set values
        
        self.name = name
        self.pixelContentSize = pixelContentSize
        self.pixelFormat = pixelFormat
        self.dataSize = dataSize
        self.contentScale = contentScale
        
        self.premultipliedAlpha = false
    }
    
    /// Creates an empty Texture
    private init() {
        
        self.name = 0
        self.pixelFormat = .RGBA8888
        self.pixelSize = (0,0) // width, height
        self.pixelContentSize = Size() // sizeInPixels
        self.contentScale = 1.0
    }
    
    public static let none = Texture()
    
    // MARK: - Methods
    
    
}

