function fn() {
    // 1. Check for the environment variable, default to 'qa' if empty
    var env = karate.env ? karate.env : 'qa';
    karate.log('Executing tests in environment:', env);

    // 2. Dynamically read the properties from the corresponding JSON file
    var config = karate.read('classpath:config/' + env + '.json');

    // 3. Global Framework Configurations
    karate.configure('connectTimeout', 5000);
    karate.configure('readTimeout', 5000);

    return config;
}