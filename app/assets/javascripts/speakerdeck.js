// Replace contentLoaded and getElementsByClassName with jQuery alternatives.

// Defines SpeakerDeck.API
((function () {
    var a, b, c = function (a, b) {
        return function () {
            return a.apply(b, arguments)
        }
    }, d = Array.prototype.slice;
    if (typeof SpeakerDeck == "undefined" || SpeakerDeck === null) SpeakerDeck = {};
    SpeakerDeck.API = function () {
        function e(b) {
            var d = this;
            this.iframe = b, this.receive = c(this.receive, this), a(window, "message", this.receive), this.on("change", function (a) {
                return d.currentSlide = a
            })
        }
        return e.prototype.send = function () {
            var a;
            return a = 1 <= arguments.length ? d.call(arguments, 0) : [], this.iframe.contentWindow.postMessage(JSON.stringify(a), "*")
        }, e.prototype.nextSlide = function () {
            return this.send("nextSlide")
        }, e.prototype.previousSlide = function () {
            return this.send("previousSlide")
        }, e.prototype.goToSlide = function (a) {
            return this.send("goToSlide", a)
        }, e.prototype.receive = function (a) {
            var b;
            if (a.data.substring(0, 4) == '_FB_') return; // FIXME
            return b = JSON.parse(a.data), this.trigger.apply(this, b)
        }, e.prototype.release = function () {
            return b(window, "message", this.receive)
        }, e.prototype.on = function (a, b) {
            var c, d, e, f, g;
            d = a.split(" "), c = this.hasOwnProperty("_callbacks") && this._callbacks || (this._callbacks = {});
            for (f = 0, g = d.length; f < g; f++) e = d[f], c[e] || (c[e] = []), c[e].push(b);
            return this
        }, e.prototype.one = function (a, b) {
            return this.on(a, function () {
                return this.off(a, arguments.callee), b.apply(this, arguments)
            })
        }, e.prototype.trigger = function () {
            var a, b, c, e, f, g, h;
            a = 1 <= arguments.length ? d.call(arguments, 0) : [], c = a.shift(), e = this.hasOwnProperty("_callbacks") && ((h = this._callbacks) != null ? h[c] : void 0);
            if (!e) return !0;
            for (f = 0, g = e.length; f < g; f++) {
                b = e[f];
                if (b.apply(this, a) === !1) return !1
            }
            return !0
        }, e.prototype.off = function (a, b) {
            var c, d, e, f, g;
            if (!a) return this._callbacks = {}, this;
            e = (g = this._callbacks) != null ? g[a] : void 0;
            if (!e) return this;
            if (!b) return delete this._callbacks[a], this;
            for (d = 0, f = e.length; d < f; d++) {
                c = e[d];
                if (c !== b) continue;
                e = e.slice(), e.splice(d, 1), this._callbacks[a] = e;
                break
            }
            return this
        }, e
    }(), a = function (a, b, c) {
        return a.addEventListener ? a.addEventListener(b, c, !1) : a.attachEvent ? a.attachEvent("on" + b, c) : a["on" + b] = c
    }, b = function (a, b, c) {
        return a.removeEventListener ? a.removeEventListener(b, c, !1) : a.detachEvent ? a.detachEvent("on" + b, c) : a["on" + b] = null
    }, this.SpeakerDeck = SpeakerDeck
})).call(this);

((function () {
    var a, b, c, d = function (a, b) {
        return function () {
            return a.apply(b, arguments)
        }
    };
    a = function () {
        function f(a, b) {
            var c;
            this.element = a, this.params = b, this.keyup = d(this.keyup, this), this.resize = d(this.resize, this), this.container = this.element.parentNode, this.id = this.element.getAttribute("data-id"), this.ratio = this.element.getAttribute("data-ratio") || 4 / 3, (c = this.params) == null && (this.params = {}), this.params.slide = this.element.getAttribute("data-slide")
        }
        var a = this;
        return f.init = function () {
            var a, b, c, d, e;
            //b = getElementsByClassName("speakerdeck-embed"), e = [];
            b = $('.speakerdeck-embed').get(), e = [];
            for (c = 0, d = b.length; c < d; c++) a = b[c], e.push((new f(a)).setup());
            return e
        }, f.prototype.url = function () {
            return "//speakerdeck.com/embed/" + this.id + "?" + this.toParam()
        }, f.prototype.toParam = function () {
            var a, b;
            return function () {
                var c, d;
                c = this.params, d = [];
                for (a in c) b = c[a], b && d.push("" + a + "=" + encodeURIComponent(b));
                return d
            }.call(this).join("&")
        }, f.prototype.setup = function () {
            return this.createFrame(), this.api = new SpeakerDeck.API(this.iframe), this.resize(), this.bindEvents(), this.insert()
        }, f.prototype.createFrame = function () {
            return this.iframe = document.createElement("iframe"), this.iframe.className = "speakerdeck-iframe", this.iframe.style["-webkit-border-radius"] = "5px", this.iframe.style["-moz-border-radius"] = "5px", this.iframe.style["border-radius"] = "5px", this.iframe.style.border = "0", this.iframe.style.background = "transparent", this.iframe.style.margin = "0", this.iframe.style.padding = "0", this.iframe.border = 0, this.iframe.frameBorder = 0, this.iframe.allowTransparency = !0, this.iframe.src = this.url(), this.iframe.setAttribute("allowfullscreen", !0), this.iframe.setAttribute("mozallowfullscreen", !0), this.iframe.setAttribute("webkitallowfullscreen", !0)
        }, f.prototype.insert = function () {
            return this.container.replaceChild(this.iframe, this.element), document.dispatchEvent(new CustomEvent("speakerdeck:player:ready", {
                detail: this.api
            }))
        }, f.prototype.resize = function () {
            return this.iframe.style.width = this.width() + "px", this.iframe.style.height = this.height() + "px"
        }, f.prototype.width = function () {
            return this.container.offsetWidth - 2
        }, f.prototype.height = function () {
            return (this.width() - 2) / this.ratio + 64
        }, f.prototype.bindEvents = function () {
            var a = this;
            return b(document, "keyup", this.keyup), b(window, "resize", c(this.resize, 100)), b(this.iframe, "load", function () {
                return a.api.send("setup")
            })
        }, f.prototype.next = function () {
            return this.api.nextSlide(), !1
        }, f.prototype.prev = function () {
            return this.api.previousSlide(), !1
        }, f.prototype.keyup = function () {
            var a, b;
            b = document.activeElement.tagName.toLowerCase();
            if (b !== "input" && b !== "textarea") {
                a = window.event ? window.event.keyCode : e.keyCode;
                switch (a) {
                case 39:
                    return this.next();
                case 37:
                    return this.prev()
                }
            }
        }, f
    }.call(this), b = function (a, b, c) {
        return a.addEventListener ? a.addEventListener(b, c, !1) : a.attachEvent ? a.attachEvent("on" + b, c) : a["on" + b] = c
    }, c = function (a, b) {
        var c;
        return c = null,
        function () {
            var d, e;
            return e = this, d = arguments, clearTimeout(c), c = setTimeout(function () {
                return a.apply(e, d)
            }, b)
        }
    },// contentLoaded(window, a.init), b(window, "popstate", a.init), b(document, "speakerdeck", a.init)
    $(a.init)
})).call(this)