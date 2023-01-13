//
//  MPVRenderView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.01.2023.
//  Copyright © 2023 Иван Морозов. All rights reserved.
//

import UIKit
import libmpv
#if targetEnvironment(macCatalyst)
import OpenGL.GL
import OpenGL.GL3
#else
import GLKit
#endif

#if targetEnvironment(macCatalyst)

class MPVRenderView: UIView {
    private var openGLContext: CGLContextObj?

    public override static var layerClass: AnyClass {
        return MPVLayer.self
    }

    public var mpvGLContext: OpaquePointer? {
        get { mpvLayer?.mpvGLContext }
        set { mpvLayer?.mpvGLContext = newValue }
    }

    public var mpvLayer: MPVLayer? {
        if let value = layer as? MPVLayer {
            return value
        }
        return nil
    }

    public func create(completion: @escaping () -> Void) {
        mpvLayer?.getGLContext({ [weak self] context in
            self?.openGLContext = context
            if context == nil {
               fatalError("Cannot create CGLContextObj!")
            }
            completion()
        })
    }

    public func draw() {
        mpvLayer?.setNeedsDisplay()
    }

}

class MPVLayer: CAOpenGLLayer {
    public var mpvGLContext: OpaquePointer?
    public var forceRender: Bool = false
    private var contextHandler: ((CGLContextObj?) -> Void)?

    override init() {
        super.init()

        isOpaque = true
        isAsynchronous = false
        contentsScale = UIScreen.main.scale
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func getGLContext(_ handler: @escaping (CGLContextObj?) -> Void) {
        if let context = CGLGetCurrentContext() {
            handler(context)
        } else {
            contextHandler = handler
        }
    }

    override func copyCGLPixelFormat(forDisplayMask mask: UInt32) -> CGLPixelFormatObj {
        var attributeList: [CGLPixelFormatAttribute] = [
            kCGLPFADoubleBuffer,
            kCGLPFAAllowOfflineRenderers,
            kCGLPFAOpenGLProfile, CGLPixelFormatAttribute(kCGLOGLPVersion_3_2_Core.rawValue),
            kCGLPFAAccelerated
        ]

        var pix: CGLPixelFormatObj?
        var npix: GLint = 0

        for index in (0..<attributeList.count).reversed() {
            let attributes = Array(
                attributeList[0...index] + [_CGLPixelFormatAttribute(rawValue: 0)]
            )
            CGLChoosePixelFormat(attributes, &pix, &npix)
            if let pix = pix {
                print("Created OpenGL pixel format with \(attributes)")
                return pix
            }
        }

        fatalError("Cannot create OpenGL pixel format!")
    }

    override func copyCGLContext(forPixelFormat pf: CGLPixelFormatObj) -> CGLContextObj {
        let ctx = super.copyCGLContext(forPixelFormat: pf)

        var i: GLint = 1
        CGLSetParameter(ctx, kCGLCPSwapInterval, &i)
        CGLEnable(ctx, kCGLCEMPEngine)

        CGLSetCurrentContext(ctx)
        contextHandler?(ctx)
        contextHandler = nil
        return ctx
    }

    // MARK: Draw
    private func shouldRenderUpdateFrame() -> Bool {
        guard let mpvGLContext = mpvGLContext else { return false }
        let flags: UInt64 = mpv_render_context_update(mpvGLContext)
        return flags & UInt64(MPV_RENDER_UPDATE_FRAME.rawValue) > 0
    }

    override func draw(inCGLContext ctx: CGLContextObj,
                       pixelFormat pf: CGLPixelFormatObj,
                       forLayerTime t: CFTimeInterval,
                       displayTime ts: UnsafePointer<CVTimeStamp>?) {
        if let mpvGLContext = self.mpvGLContext {
            let width =  Int32(self.frame.width * self.contentsScale)
            let height = Int32(self.frame.height * self.contentsScale)

            var fboName: GLint = 1
            glGetIntegerv(GLenum(GL_DRAW_FRAMEBUFFER_BINDING), &fboName)

            var openglFbo = mpv_opengl_fbo(fbo: Int32(fboName), w: width, h: height, internal_format: 0)
            let openglFboPoniter = UnsafeMutableRawPointer(mutating: withUnsafePointer(to: &openglFbo) { $0 })
            let flipYponiter = UnsafeMutableRawPointer(mutating: withUnsafePointer(to: 1) { $0 })

            var params = [
                mpv_render_param(type: MPV_RENDER_PARAM_OPENGL_FBO, data: openglFboPoniter),
                mpv_render_param(type: MPV_RENDER_PARAM_FLIP_Y, data: flipYponiter),
                mpv_render_param()
            ]
            mpv_render_context_render(mpvGLContext, &params)
        } else {
            fillBlack()
        }

        super.draw(inCGLContext: ctx, pixelFormat: pf, forLayerTime: t, displayTime: ts)
    }

    private func fillBlack() {
        glClearColor(0, 0, 1, 0)
        glClear(UInt32(GL_COLOR_BUFFER_BIT))
    }

}

#else

class MPVRenderView: UIView {
    private var context: EAGLContext?
    private var fboName: GLuint = 0
    private var colorRenderbuffer: GLuint = 0
    private var depthRenderbuffer: GLuint = 0

    public override static var layerClass: AnyClass {
        return CAEAGLLayer.self
    }

    public var mpvGLContext: OpaquePointer?

    public var glLayer: CAEAGLLayer? {
        if let value = layer as? CAEAGLLayer {
            return value
        }
        return nil
    }

    public func create(completion: @escaping () -> Void) {
        self.setup()
        completion()
    }

    public func draw() {
        let width =  Int32(self.frame.width * self.contentScaleFactor)
        let height = Int32(self.frame.height * self.contentScaleFactor)
        render(width: width, height: height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateViewport()
    }

    private func setup() {
        guard let context = EAGLContext(api: .openGLES3) else { return }
        self.context = context
        EAGLContext.setCurrent(context)
        setupLayer()
        setupBuffers()
    }

    private func setupLayer() {
        glLayer?.isOpaque = true
        glLayer?.contentsScale = UIScreen.main.scale
        glLayer?.drawableProperties = [
            kEAGLDrawablePropertyRetainedBacking: NSNumber(false),
            kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
        ]
    }

    private func setupBuffers() {
        glGenFramebuffers(1, &fboName)
        glGenRenderbuffers(1, &colorRenderbuffer)

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), fboName)

        glGetIntegerv(GLenum(GL_DRAW_FRAMEBUFFER_BINDING), &i)

        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderbuffer)
        context?.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.glLayer)

        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRenderbuffer)

        let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
        if status != GL_FRAMEBUFFER_COMPLETE {
            preconditionFailure("failed to make complete framebuffer object \(status)")
        }
    }

    private func updateViewport() {
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderbuffer)
        context?.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.glLayer)

        var backingWidth: GLint = 0
        var backingHeight: GLint = 0

        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_WIDTH), &backingWidth)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_HEIGHT), &backingHeight)

        glViewport(0, 0, backingWidth, backingHeight)
    }

    private func render(width: Int32, height: Int32) {
        EAGLContext.setCurrent(self.context)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), fboName)

        if let mpvGLContext = self.mpvGLContext {

            var openglFbo = mpv_opengl_fbo(fbo: Int32(fboName), w: width, h: height, internal_format: 0)
            let openglFboPoniter = UnsafeMutableRawPointer(mutating: withUnsafePointer(to: &openglFbo) { $0 })
            let flipYponiter = UnsafeMutableRawPointer(mutating: withUnsafePointer(to: 1) { $0 })

            var params = [
                mpv_render_param(type: MPV_RENDER_PARAM_OPENGL_FBO, data: openglFboPoniter),
                mpv_render_param(type: MPV_RENDER_PARAM_FLIP_Y, data: flipYponiter),
                mpv_render_param()
            ]
            mpv_render_context_render(mpvGLContext, &params)
            glFlush()
        } else {
            fillBlack()
        }

        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderbuffer)
        context?.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }

    private func fillBlack() {
        glClearColor(0, 0, 0, 0)
        glClear(UInt32(GL_COLOR_BUFFER_BIT))
    }

    deinit {
        glDeleteFramebuffers(1, &fboName)
        glDeleteRenderbuffers(1, &colorRenderbuffer)
        glDeleteRenderbuffers(1, &depthRenderbuffer)
        EAGLContext.setCurrent(nil)
    }
}

#endif
