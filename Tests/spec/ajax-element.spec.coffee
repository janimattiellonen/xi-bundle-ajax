if require?
    require "../../../JsTestBundle/Resources/config/init-test.coffee"

    # file to test    
    require "../../Resources/coffee/ajax-element.coffee"

describe "ajax-element", ->

    element = $('<a id="linkster" href="#">tussi</a>')
    ajaxElement = null

    beforeEach ->
        $('body').append element
        ajaxElement = new App.AjaxElement.Default 'a#linkster'

    afterEach ->
        element.remove()

    it "instantiates", ->
        expect(ajaxElement).toBeDefined()

    # some kind of a scope problem
    xit "launches on default event(s) and does proper pre handling", ->

        ajaxElemConfig = ajaxElement.getConfiguration()

        spyOn($, "ajax").andCallFake (params) ->
            params.beforeSend {}, element, {}
            params.success {success:{id: 1, value: "dingdong"}}

        spyOn ajaxElemConfig, "beforeSubmit"
        spyOn ajaxElemConfig, "success"
        spyOn ajaxElement, "preHandleResponse"
        spyOn ajaxElement, "handleSuccess"

        element.click()

        # expect(ajaxElement.currentElement).not.toBeNull()
        # expect(ajaxElement.currentElement.attr('id')).toEqual "linkster"

        expect(ajaxElemConfig.beforeSubmit).toHaveBeenCalled()
        expect(ajaxElement.preHandleResponse).toHaveBeenCalled()

        expect(ajaxElemConfig.success).toHaveBeenCalled()
        expect(ajaxElement.handleSuccess).toHaveBeenCalled()


    it "launches on default event(s) and fails", ->

        ajaxElemConfig = ajaxElement.getConfiguration()

        spyOn($, "ajax").andCallFake (params) ->
            params.success "failing response"

        spyOn ajaxElement, "handleFailure"

        element.click()

        expect(ajaxElement.handleFailure).toHaveBeenCalled()
        expect(ajaxElement.handleFailure.mostRecentCall.args[0]).toEqual "failing response"


describe "element errorizer", ->

    link = $('<a id="linkster" href="#">tussi</a>')
    elementErrorizer = null

    beforeEach ->
        $('body').append link
        elementErrorizer = new App.ElementErrorizer.Default()

    afterEach ->
        link.remove()
        # remove this on cases where we don't want to wait for the delay
        $('.errorized-element').remove()

    it "errorizers", ->
        response = {failure: 'this is fail'}
        result = elementErrorizer.errorize link, response

        expect(result).toBeTruthy()

        # expect($('.errorized-element').length).toBeGreaterThan 0

    it "does nothing on a non-valid fail response", ->
        response = "more fail"
        result = elementErrorizer.errorize link, response

        expect($('.errorized-element').length).toEqual 0
        expect(result).toBeFalsy()

    # node-jquery (?) fails
    xit "makes sure errors are removed after waiting", ->

        runs ->
            response = {failure: 'this is fail'}
            elementErrorizer.errorize link, response
            expect($('.errorized-element').length).toBeGreaterThan 0

        waits 3000

        runs ->
            expect($('.errorized-element').length).toEqual 0


    xit "clears errorizers", ->
        runs ->
            response = {failure: 'this is fail'}
            elementErrorizer.errorize link, response

            expect($('.errorized-element').length).toBeGreaterThan 0

            elementErrorizer.clear()

        # "slow" animation is supposed to mean 600 ms
        # but how come we need this much?
        waits 3000
        
        runs ->
            console.log $('.errorized-element')
            expect($('.errorized-element').length).toEqual 0