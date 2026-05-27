package utils;

import java.util.Random;

public class DataGenerator {

    /**
     * Generates a random 4-digit string ID between 1000 and 9999.
     */
    public static String getRandomFourDigitId() {
        Random random = new Random();
        // Generates a number from 0 to 8999, then adds 1000 to ensure it's 4 digits
        int id = random.nextInt(9000) + 1000;
        return String.valueOf(id);
    }
}