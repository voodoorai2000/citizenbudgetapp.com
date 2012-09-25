# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
CitizenBudget::Application.config.secret_token = ENV['SECRET_TOKEN'] || '714958043cf91bf936b885007173d262f2929822988928ff8490875f70bf8828cf63680c776abbdefc13dec8d8695111d6c91298147e628542992566091591aa'
