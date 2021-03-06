import El from 'el.js'

import Events from '../events'
import html   from '../../templates/forms/form'
import m      from '../mediator'
import {
  isPassword,
  isRequired,
  matchesPassword
  splitName,
} from './middleware'

class RegisterComplete extends El.Views.Form
  tag: 'register-complete'
  html: html

  twoStageSignUp: false

  configs:
    'user.name':                [ isRequired, splitName ]
    'user.password':            [ isPassword ]
    'user.passwordConfirm':     [ isPassword, matchesPassword ]

  errorMessage: ''

  init: ->
    super

    if !@twoStageSignUp
      @_submit()

  _submit: (event) ->
    opts =
      password:         @data.get 'user.password'
      passwordConfirm:  @data.get 'user.passwordConfirm'
      tokenId:          @data.get 'tokenId'

    firstName = @data.get 'user.firstName'
    lastName = @data.get 'user.lastName'

    if firstName
      opts.firstName = firstName
    if lastName
      opts.lastName = lastName

    @errorMessage = ''

    @scheduleUpdate()
    m.trigger Events.RegisterComplete
    @client.account.enable(opts).then (res) =>
      if res.token
        @client.setCustomerToken res.token
      m.trigger Events.RegisterCompleteSuccess, res
      @scheduleUpdate()
    .catch (err)=>
      @errorMessage = err.message
      m.trigger Events.RegisterCompleteFailed, err
      @scheduleUpdate()

export default RegisterComplete
